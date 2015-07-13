require "measured"
require "minitest/autorun"
require "mocha/setup"
require "pry"

ActiveSupport.test_order = :random

require "support/fake_system"

class ActiveSupport::TestCase

  protected

  def assert_conversion(klass, from, to)
    from_amount, from_unit = from.split(" ")
    to_amount, to_unit = to.split(" ")

    assert_equal BigDecimal(to_amount).round(5), klass.new(from_amount, from_unit).convert_to(to_unit).value.round(5)
  end
end
