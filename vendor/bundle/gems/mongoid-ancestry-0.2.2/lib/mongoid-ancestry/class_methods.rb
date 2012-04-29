module Mongoid
  module Ancestry
    module ClassMethods
      def has_ancestry(opts = {})
        defaults = {
          :ancestry_field    => :ancestry,
          :cache_depth       => false,
          :depth_cache_field => :ancestry_depth,
          :orphan_strategy   => :destroy
        }

        valid_opts = [:ancestry_field, :cache_depth, :depth_cache_field, :orphan_strategy]
        unless opts.is_a?(Hash) &&  opts.keys.all? {|opt| valid_opts.include?(opt) }
          raise Error.new("Invalid options for has_ancestry. Only hash is allowed.\n Defaults: #{defaults.inspect}")
        end

        opts.symbolize_keys!

        opts.reverse_merge!(defaults)

        # Create ancestry field accessor and set to option or default
        cattr_accessor :ancestry_field
        self.ancestry_field = opts[:ancestry_field]

        self.field ancestry_field, :type => String
        self.index ancestry_field

        # Create orphan strategy accessor and set to option or default (writer comes from DynamicClassMethods)
        cattr_reader :orphan_strategy
        self.orphan_strategy = opts[:orphan_strategy]

        # Validate format of ancestry column value
        primary_key_format = opts[:primary_key_format] || /[a-z0-9]+/
        validates_format_of ancestry_field, :with => /\A#{primary_key_format.source}(\/#{primary_key_format.source})*\Z/, :allow_nil => true

        # Validate that the ancestor ids don't include own id
        validate :ancestry_exclude_self

        # Create ancestry column accessor and set to option or default
        if opts[:cache_depth]
          # Create accessor for column name and set to option or default
          self.cattr_accessor :depth_cache_field
          self.depth_cache_field = opts[:depth_cache_field]

          # Cache depth in depth cache column before save
          before_validation :cache_depth

          # Validate depth column
          validates_numericality_of depth_cache_field, :greater_than_or_equal_to => 0, :only_integer => true, :allow_nil => false
        end

        # Create named scopes for depth
        {:before_depth => 'lt', :to_depth => 'lte', :at_depth => nil, :from_depth => 'gte', :after_depth => 'gt'}.each do |scope_name, operator|
          scope scope_name, lambda { |depth|
            raise Error.new("Named scope '#{scope_name}' is only available when depth caching is enabled.") unless opts[:cache_depth]
            where( (operator ? depth_cache_field.send(operator.to_sym) : depth_cache_field) => depth)
          }
        end

        scope :roots, where(ancestry_field => nil)
        scope :ancestors_of, lambda { |object| where(to_node(object).ancestor_conditions) }
        scope :children_of, lambda { |object| where(to_node(object).child_conditions) }
        scope :descendants_of, lambda { |object| any_of(to_node(object).descendant_conditions) }
        scope :subtree_of, lambda { |object| any_of(to_node(object).subtree_conditions) }
        scope :siblings_of, lambda { |object| where(to_node(object).sibling_conditions) }
        scope :ordered_by_ancestry, asc(:"#{self.base_class.ancestry_field}")
        scope :ordered_by_ancestry_and, lambda {|by| ordered_by_ancestry.order_by([by]) }

        # Update descendants with new ancestry before save
        before_save :update_descendants_with_new_ancestry

        # Apply orphan strategy before destroy
        before_destroy :apply_orphan_strategy
      end

      # Fetch tree node if necessary
      def to_node object
        object.is_a?(self.base_class) ? object : find(object)
      end

      # Scope on relative depth options
      def scope_depth depth_options, depth
        depth_options.inject(self.base_class) do |scope, option|
          scope_name, relative_depth = option
          if [:before_depth, :to_depth, :at_depth, :from_depth, :after_depth].include? scope_name
            scope.send scope_name, depth + relative_depth
          else
            raise Error.new("Unknown depth option: #{scope_name}.")
          end
        end
      end

      # Orphan strategy writer
      def orphan_strategy= orphan_strategy
        # Check value of orphan strategy, only rootify, restrict or destroy is allowed
        if [:rootify, :restrict, :destroy].include? orphan_strategy
          class_variable_set :@@orphan_strategy, orphan_strategy
        else
          raise Error.new("Invalid orphan strategy, valid ones are :rootify, :restrict and :destroy.")
        end
      end

      # Arrangement
      def arrange options = {}
        scope =
          if options[:order].nil?
            self.base_class.ordered_by_ancestry
          else
            self.base_class.ordered_by_ancestry_and options.delete(:order)
          end
        # Get all nodes ordered by ancestry and start sorting them into an empty hash
        scope.all(options).inject(ActiveSupport::OrderedHash.new) do |arranged_nodes, node|
          # Find the insertion point for that node by going through its ancestors
          node.ancestor_ids.inject(arranged_nodes) do |insertion_point, ancestor_id|
            insertion_point.each do |parent, children|
              # Change the insertion point to children if node is a descendant of this parent
              insertion_point = children if ancestor_id == parent.id
            end; insertion_point
          end[node] = ActiveSupport::OrderedHash.new; arranged_nodes
        end
      end

      # Integrity checking
      def check_ancestry_integrity! options = {}
        parents = {}
        exceptions = [] if options[:report] == :list
        # For each node ...
        self.base_class.all.each do |node|
          begin
            # ... check validity of ancestry column
            if !node.valid? and !node.errors[node.class.ancestry_field].blank?
              raise IntegrityError.new "Invalid format for ancestry column of node #{node.id}: #{node.read_attribute node.ancestry_field}."
            end
            # ... check that all ancestors exist
            node.ancestor_ids.each do |ancestor_id|
              unless where(:_id => ancestor_id).first
                raise IntegrityError.new "Reference to non-existent node in node #{node.id}: #{ancestor_id}."
              end
            end
            # ... check that all node parents are consistent with values observed earlier
            node.path_ids.zip([nil] + node.path_ids).each do |node_id, parent_id|
              parents[node_id] = parent_id unless parents.has_key? node_id
              unless parents[node_id] == parent_id
                raise IntegrityError.new "Conflicting parent id found in node #{node.id}: #{parent_id || 'nil'} for node #{node_id} while expecting #{parents[node_id] || 'nil'}"
              end
            end
          rescue IntegrityError => integrity_exception
            case options[:report]
            when :list then exceptions << integrity_exception
            when :echo then puts integrity_exception
            else raise integrity_exception
            end
          end
        end
        exceptions if options[:report] == :list
      end

      # Integrity restoration
      def restore_ancestry_integrity!
        parents = {}
        # For each node ...
        self.base_class.all.each do |node|
          # ... set its ancestry to nil if invalid
          if node.errors[node.class.ancestry_field].blank?
            node.without_ancestry_callbacks do
              node.update_attribute node.ancestry_field, nil
            end
          end
          # ... save parent of this node in parents array if it exists
          parents[node.id] = node.parent_id if exists? node.parent_id

          # Reset parent id in array to nil if it introduces a cycle
          parent = parents[node.id]
          until parent.nil? || parent == node.id
            parent = parents[parent]
          end
          parents[node.id] = nil if parent == node.id
        end
        # For each node ...
        self.base_class.all.each do |node|
          # ... rebuild ancestry from parents array
          ancestry, parent = nil, parents[node.id]
          until parent.nil?
            ancestry, parent = if ancestry.nil? then parent else "#{parent}/#{ancestry}" end, parents[parent]
          end
          node.without_ancestry_callbacks do
            node.update_attribute node.ancestry_field, ancestry
          end
        end
      end

      # Build ancestry from parent id's for migration purposes
      def build_ancestry_from_parent_ids! parent_id = nil, ancestry = nil
        self.base_class.where(:parent_id => parent_id).all.each do |node|
          node.without_ancestry_callbacks do
            node.update_attribute(self.base_class.ancestry_field, ancestry)
          end
          build_ancestry_from_parent_ids! node.id,
            if ancestry.nil? then node.id.to_s else "#{ancestry}/#{node.id}" end
        end
      end

      # Rebuild depth cache if it got corrupted or if depth caching was just turned on
      def rebuild_depth_cache!
        raise Error.new("Cannot rebuild depth cache for model without depth caching.") unless respond_to? :depth_cache_field
        self.base_class.all.each do |node|
          node.update_attribute depth_cache_field, node.depth
        end
      end
    end
  end
end
