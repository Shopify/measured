# frozen_string_literal: true
require "pry" unless ENV["CI"]
require "measured"
require "minitest/reporters"
require "minitest/autorun"
require "mocha/setup"

Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new(color: true)]

require "support/subclasses"
require "support/fake_system"
require "support/always_true_cache"

class Minitest::Test
  class << self
    def test(name, &block)
      test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
      raise "#{test_name} is already defined in #{self}" if method_defined?(test_name)

      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end

    def setup(&block)
      define_method(:setup, &block)
    end

    def teardown(&block)
      define_method(:teardown, &block)
    end
  end

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
    error = assert_raises(exception) { yield }
    assert_equal expected_message, error.message, "Exception #{exception} raised but messages are not equal"
  end
end
