# encoding: utf-8
require 'rails_best_practices/reviews/review'

module RailsBestPractices
  module Reviews
    # Review config/routes file to make sure not use default route that rails generated.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/12-not-use-default-route-if-you-use-restful-design
    #
    # Implementation:
    #
    # Review process:
    #   check all method command_call or command node to see if it is the same as rails default route.
    #
    #     map.connect ':controller/:action/:id'
    #     map.connect ':controller/:action/:id.:format'
    #
    #   or
    #
    #     match ':controller(/:action(/:id(.:format)))'
    class NotUseDefaultRouteReview < Review
      interesting_nodes :command_call, :command
      interesting_files ROUTE_FILES

      def url
        "http://rails-bestpractices.com/posts/12-not-use-default-route-if-you-use-restful-design"
      end

      # check all command call nodes, compare with rails2 default route
      def start_command_call(node)
        if "map" == node.subject.to_s && "connect" == node.message.to_s &&
          (":controller/:action/:id" == node.arguments.all.first.to_s ||
           ":controller/:action/:id.:format" == node.arguments.all.first.to_s)
          add_error "not use default route"
        end
      end

      # check all command nodes, compare with rails3 default route
      def start_command(node)
        if "match" == node.message.to_s &&
          ":controller(/:action(/:id(.:format)))" == node.arguments.all.first.to_s
          add_error "not use default route"
        end
      end
    end
  end
end
