require 'test_helper'
require 'minitest/fire_mock'

class FireMockTest < MiniTest::Unit::TestCase
  def test_mock_is_valid_when_not_defined
    mock = MiniTest::FireMock.new('NotDefinedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_is_valid_when_defined_and_responds_to_method
    mock = MiniTest::FireMock.new('DefinedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_is_invalid_when_defined_but_dont_responds_to_method
    mock = MiniTest::FireMock.new('DefinedConstant')
    assert_raises MockExpectationError, "expected Foo to define `not_defined_method`, but it doesn't" do
      mock.expect(:not_defined_method, 42)
    end
  end

  def test_mock_with_namespace_is_valid_when_not_defined
    mock = MiniTest::FireMock.new('Namespace::NotDefinedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_with_namespace_is_valid_when_defined_and_responds_to_method
    mock = MiniTest::FireMock.new('Namespace::NamespacedConstant')
    mock.expect(:defined_method, 42)
    assert_equal 42, mock.defined_method
    mock.verify
  end

  def test_mock_with_namespace_is_invalid_when_defined_but_dont_responds_to_method
    mock = MiniTest::FireMock.new('Namespace::NamespacedConstant')
    assert_raises MockExpectationError, "expected Foo to define `not_defined_method`, but it doesn't" do
      mock.expect(:not_defined_method, 42)
    end
  end

  def test_valid_mock_with_different_arity
    mock = MiniTest::FireMock.new('DefinedConstant')
    assert_raises MockExpectationError, "`defined_method` expects 0 arguments, given 3" do
      mock.expect(:defined_method, 42, [1,2,3])
    end
  end
end
