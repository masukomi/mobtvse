# encoding: utf-8
require 'rails_best_practices/core/check'

module RailsBestPractices
  module Lexicals
    # Make sure there are no trailing whitespace in codes.
    #
    # See the best practice details here http://rails-bestpractices.com/posts/60-remove-trailing-whitespace
    class RemoveTrailingWhitespaceCheck < Core::Check
      def url
        "http://rails-bestpractices.com/posts/60-remove-trailing-whitespace"
      end

      # check if the content of file contain a trailing whitespace.
      #
      # @param [String] filename name of the file
      # @param [String] content content of the file
      def check(filename, content)
        if content =~ / +\n/m
          line_no = $`.count("\n") + 1
          add_error("remove trailing whitespace", filename, line_no)
        end
      end
    end
  end
end
