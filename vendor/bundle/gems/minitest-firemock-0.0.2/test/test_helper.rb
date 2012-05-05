require 'minitest/unit'

MiniTest::Unit.autorun

class DefinedConstant
  def defined_method; end
end

module Namespace
  class NamespacedConstant
    def defined_method; end
  end
end
