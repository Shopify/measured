# frozen_string_literal: true

require "pry" unless ENV["CI"]
require "combustion"
Combustion.path = "test/internal"
Combustion.initialize! :active_record, :active_model
require "measured"
require "minitest/reporters"
require "minitest/autorun"
require "mocha/minitest"

ActiveSupport.test_order = :random

# Prevent two reporters from printing
# https://github.com/kern/minitest-reporters/issues/230
# https://github.com/rails/rails/issues/30491
Minitest.load_plugins
Minitest.extensions.delete('rails')
Minitest.extensions.unshift('rails')

Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new(color: true)]

require "support/subclasses"
require "support/fake_system"
require "support/always_true_cache"

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

  def reset_db
    Combustion::Database::LoadSchema.call
  end
end
