# frozen_string_literal: true
require "test_helper"

class Measured::UnitConversionTest < ActiveSupport::TestCase
  setup do
    @unit_conversion = Measured::UnitConversion.parse("10 Cake")
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal 10, @unit_conversion.amount
    assert_equal "Cake", @unit_conversion.unit

    unit_conversion = Measured::UnitConversion.parse(["5.5", "sweets"])
    assert_equal BigDecimal("5.5"), unit_conversion.amount
    assert_equal "sweets", unit_conversion.unit

    unit_conversion = Measured::UnitConversion.parse("1/3 bitter pie")
    assert_equal Rational(1, 3), unit_conversion.amount
    assert_equal "bitter pie", unit_conversion.unit
  end

  test "#initialize raises if the format of the value is incorrect" do
    assert_raises Measured::UnitError do
      Measured::UnitConversion.parse("hello")
    end

    assert_raises Measured::UnitError do
      Measured::UnitConversion.parse("123456")
    end
  end

  test "#to_s returns an expected string" do
    assert_nil Measured::UnitConversion.parse(nil).to_s
    assert_equal "1/2 sweet", Measured::UnitConversion.parse("0.5 sweet").to_s
  end

  test "#inverse_amount returns 1/amount" do
    assert_equal Rational(1, 10), @unit_conversion.inverse_amount
  end

  test "#inverse_amount handles nil for base unit" do
    assert_nil Measured::UnitConversion.parse(nil).inverse_amount
  end
end

class Measured::StaticUnitConversionTest < ActiveSupport::TestCase
  setup do
    @unit_conversion = Measured::UnitConversion.parse("10 Cake")
  end

  test "#static? & #dynamic?" do
    refute @unit_conversion.dynamic?
    assert @unit_conversion.static?
  end

  test "#to_dynamic maps a static unit into a dynamic one" do
    new_unit = @unit_conversion.to_dynamic

    assert_equal "Cake", new_unit.unit
    assert_equal "10/1 Cake", new_unit.to_s

    assert new_unit.amount.is_a?(Proc)
    assert_equal 10, new_unit.amount.call(1)

    assert new_unit.inverse_amount.is_a?(Proc)
    assert_equal 1, new_unit.inverse_amount.call(10)
  end
end

class Measured::DynamicUnitConversionTest < ActiveSupport::TestCase
  setup do
    @unit_conversion = Measured::UnitConversion.parse([
      {
        conversion: proc { |x| x * Rational(10, 1) },
        reverse_conversion: proc { |x| x * Rational(1, 10) }
      },
      "sweets"
    ])
  end

  test "#static? & #dynamic?" do
    assert @unit_conversion.dynamic?
    refute @unit_conversion.static?
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal 10, @unit_conversion.amount.call(1)
    assert_equal "sweets", @unit_conversion.unit
  end

  test "#to_s returns an expected string" do
    assert_nil @unit_conversion.to_s

    unit_conversion = Measured::UnitConversion.parse([
      {
        conversion: proc { |x| x * Rational(10, 1) },
        reverse_conversion: proc { |x| x * Rational(1, 10) },
        description: 'some description'
      },
      "sweets"
    ])

    assert_equal 'some description', unit_conversion.to_s
  end

  test "#inverse_amount returns 1/amount" do
    assert_equal 0.1, @unit_conversion.inverse_amount.call(1)
  end

  test "#to_dynamic returns itself" do
    assert @unit_conversion.to_dynamic == @unit_conversion
  end
end
