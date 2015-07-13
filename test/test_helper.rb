require "measured"
require "minitest/autorun"
require "mocha/setup"
require "pry"

ActiveSupport.test_order = :random

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

    assert_close_bigdecimal BigDecimal(to_amount), klass.new(from_amount, from_unit).convert_to(to_unit).value
  end
end
