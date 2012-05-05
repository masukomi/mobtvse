MiniTest::FireMock
==================

This gem was designed do make isolated tests more resilient. In isolated tests, a FireMock is no different than a common mock. The only difference is when the test is called on a not-isolated environment. It checks for the presence of the method on the mocked class, and fails if it isn't there. This adds another layer of security for suit tests, without compromising the isolation of unit tests.

It's based on the awesome [rspec-fire](https://github.com/xaviershay/rspec-fire) from [Xavier Shay](http://xaviershay.com/).

Usage
-----

```ruby
require 'minitest/autorun'
require 'minitest/fire_mock'

class MyClass
  def my_method
    # actual_work goes here
  end
end

class MyOtherClassTest < MiniTest::Unit::TestCase
  def test_for_correctness
    mock = MiniTest::FireMock('MyClass')
    mock.expect(:my_method, 42)
    assert_equal 42, mock.my_method
    mock.verify
  end
end
```

The only real difference of using `MiniTest::FireMock` instead of `MiniTest::Mock` is that if `MyClass` is defined, and `my_method` isn't there, it'll raise a `MockExpectationError`. It checks also for the arity of the method, so it'll raise a `MockExpectationError` if the real method have a different arity than the expectation.

TODO
----

- Mock class/module methods too.
- Make it work with method_missing (as of now it doesn't, even if the #responds_to? is correct)
