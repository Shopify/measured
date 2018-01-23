require "measured"
require "minitest/reporters"
require "minitest/autorun"
require "mocha/setup"
require "pry" unless ENV["CI"]

ActiveSupport.test_order = :random

Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new(color: true)]

require "support/fake_system"

class ActiveSupport::TestCase

  protected

  def assert_close_bigdecimal exp, act, delta = BigDecimal('0.000001')
    n = (exp - act).abs
    msg = message(msg) {
      "Expected #{act.inspect} to be\nclose to #{exp.inspect} within #{delta} but was within #{n}"
    }
    assert delta >= n, msg
  end

  def assert_conversion(klass, from, to)
    from_amount, from_unit = from.split(" ")
    to_amount, to_unit = to.split(" ")

    to_unit = klass.unit_system.unit_for!(to_unit)
    assert_close_bigdecimal BigDecimal(to_amount), klass.new(from_amount, from_unit).convert_to(to_unit).value
  end

  def assert_exact_conversion(klass, from, to)
    from_amount, from_unit = from.split(" ")
    to_amount, to_unit = to.split(" ")

    to_unit = klass.unit_system.unit_for!(to_unit)
    assert_equal BigDecimal(to_amount), klass.new(from_amount, from_unit).convert_to(to_unit).value
  end

  def assert_raises_with_message(exception, expected_message)
    error = assert_raise(exception) { yield }
    assert_equal expected_message, error.message, "Exception #{exception} raised but messages are not equal"
  end
end
