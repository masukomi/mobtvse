# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Prepares
    # Remembber routes.
    class RoutePrepare < Core::Check
      interesting_nodes :command, :command_call, :method_add_block, :do_block, :brace_block
      interesting_files ROUTE_FILES

      RESOURCES_ACTIONS = %w(index show new create edit update destroy)
      RESOURCE_ACTIONS = %w(show new create edit update destroy)

      def initialize
        @routes = Prepares.routes
        @namespaces = []
        @controller_names = []
      end

      # remember route for rails3.
      def start_command(node)
        case node.message.to_s
        when "resources"
          add_resources_routes(node)
        when "resource"
          add_resource_routes(node)
        when "get", "post", "put", "delete"
          first_argument = node.arguments.all.first
          second_argument = node.arguments.all[1]
          if @controller_names.last
            if :bare_assoc_hash == first_argument.sexp_type
              action_names = [first_argument.hash_values.first.to_s]
            elsif :array == first_argument.sexp_type
              action_names = first_argument.array_values.map(&:to_s)
            else
              action_names = [first_argument.to_s]
            end
            action_names.each do |action_name|
              @routes.add_route(current_namespaces, current_controller_name, action_name)
            end
          else
            if :bare_assoc_hash == first_argument.sexp_type
              route_node = first_argument.hash_values.first
              # do not parse redirect block
              return if :method_add_arg == route_node.sexp_type
              controller_name, action_name = route_node.to_s.split('#')
            elsif :array == first_argument.sexp_type
              first_argument.array_values.map(&:to_s).each do |action_node|
                @routes.add_route(current_namespaces, controller_name, action_node.to_s)
              end
              return
            elsif :bare_assoc_hash == second_argument.try(:sexp_type)
              if second_argument.hash_value("to").present?
                controller_name, action_name = second_argument.hash_value("to").to_s.split('#')
              else
                controller_name = current_controller_name
                action_name = second_argument.hash_value("action")
              end
            else
              controller_name, action_name = first_argument.to_s.split('/')
            end
            @routes.add_route(current_namespaces, controller_name.try(:underscore), action_name)
          end
        when "match", "root"
          options = node.arguments.all.last
          case options.sexp_type
          when :bare_assoc_hash
            if options.hash_value("controller").present?
              return if :regexp_literal == options.hash_value("controller").sexp_type
              controller_name = options.hash_value("controller").to_s
              action_name = options.hash_value("action").present? ? options.hash_value("action").to_s : "*"
              @routes.add_route(current_namespaces, controller_name, action_name)
            else
              route_node = options.hash_values.find { |value_node| :string_literal == value_node.sexp_type && value_node.to_s.include?('#') }
              if route_node.present?
                controller_name, action_name = route_node.to_s.split('#')
                @routes.add_route(current_namespaces, controller_name.underscore, action_name)
              end
            end
          when :string_literal, :symbol_literal
            if current_controller_name
              @routes.add_route(current_namespaces, current_controller_name, options.to_s)
            end
          else
            # do nothing
          end
        else
          # nothing to do
        end
      end

      # remember route for rails2.
      def start_command_call(node)
        case node.message.to_s
        when "resources"
          add_resources_routes(node)
        when "resource"
          add_resource_routes(node)
        when "namespace"
          # nothing to do
        else
          options = node.arguments.all.last
          if options.hash_value("controller").present?
            @controller_name = [:option, options.hash_value("controller").to_s]
          end
          action_name = options.hash_value("action").present? ? options.hash_value("action").to_s : "*"
          @routes.add_route(current_namespaces, current_controller_name, action_name)
        end
      end

      # remember the namespace.
      def start_method_add_block(node)
        case node.message.to_s
        when "namespace"
          @namespaces << node.arguments.all.first.to_s
          @controller_name = nil
        when "scope"
          if node.arguments.all.last.hash_value("module").present?
            @namespaces << node.arguments.all.last.hash_value("module").to_s
          end
          if node.arguments.all.last.hash_value("controller").present?
            @controller_name = [:scope, node.arguments.all.last.hash_value("controller").to_s]
          else
            @controller_name = @controller_name.try(:first) == :scope ? @controller_name : nil
          end
        when "with_options"
          argument = node.arguments.all.last
          if :bare_assoc_hash == argument.sexp_type && argument.hash_value("controller").present?
            @controller_name = [:with_option, argument.hash_value("controller").to_s]
          end
        else
          # do nothing
        end
      end

      # end of namespace call.
      def end_method_add_block(node)
        case node.message.to_s
        when "namespace"
          @namespaces.pop
        when "scope"
          if node.arguments.all.last.hash_value("module").present?
            @namespaces.pop
          end
        else
          # do nothing
        end
      end

      # remember current controller name, used for nested resources.
      def start_do_block(node)
        @controller_names << @controller_name.try(:last)
      end

      # remove current controller name, and use upper lever resource name.
      def end_do_block(node)
        @controller_names.pop
      end

      alias_method :start_brace_block, :start_do_block
      alias_method :end_brace_block, :end_do_block

      [:resources, :resource].each do |route_name|
        class_eval <<-EOF
        def add_#{route_name}_routes(node)
          resource_names = node.arguments.all.select { |argument| :symbol_literal == argument.sexp_type }
          resource_names.each do |resource_name|
            @controller_name = [:#{route_name}, node.arguments.all.first.to_s]
            options = node.arguments.all.last
            if options.hash_value("module").present?
              @namespaces << options.hash_value("module").to_s
            end
            if options.hash_value("controller").present?
              @controller_name = [:#{route_name}, options.hash_value("controller").to_s]
            end
            action_names = if options.hash_value("only").present?
                             get_#{route_name}_actions(options.hash_value("only").to_object)
                           elsif options.hash_value("except").present?
                             self.class.const_get(:#{route_name.to_s.upcase}_ACTIONS) - get_#{route_name}_actions(options.hash_value("except").to_object)
                           else
                             self.class.const_get(:#{route_name.to_s.upcase}_ACTIONS)
                           end
            action_names.each do |action_name|
              @routes.add_route(current_namespaces, current_controller_name, action_name)
            end

            member_routes = options.hash_value("member")
            if member_routes.present?
              action_names = :array == member_routes.sexp_type ? member_routes.to_object : member_routes.hash_keys
              action_names.each do |action_name|
                @routes.add_route(current_namespaces, current_controller_name, action_name)
              end
            end

            collection_routes = options.hash_value("collection")
            if collection_routes.present?
              action_names = :array == collection_routes.sexp_type ? collection_routes.to_object : collection_routes.hash_keys
              action_names.each do |action_name|
                @routes.add_route(current_namespaces, current_controller_name, action_name)
              end
            end
            if options.hash_value("module").present?
              @namespaces.pop
            end
          end
        end

        def get_#{route_name}_actions(action_names)
          case action_names
          when "all"
            self.class.const_get(:#{route_name.to_s.upcase}_ACTIONS)
          when "none"
            []
          else
            Array(action_names)
          end
        end

        def add_customize_routes
        end
        EOF
      end

      def current_namespaces
        @namespaces.dup
      end

      def current_controller_name
        @controller_names.last || @controller_name.try(:last)
      end
    end
  end
end
