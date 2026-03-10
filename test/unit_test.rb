# frozen_string_literal: true
require "test_helper"

class Measured::UnitTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::Unit.new(:Pie, value: "10 Cake")
    @unit_with_aliases = Measured::Unit.new(:Pie, aliases: %w(Cake Tart))
  end

  test "#initialize converts the name to a string" do
    assert_equal "Pie", @unit.name
  end

  test "#initialize converts aliases to strings and makes a list of sorted names" do
    assert_equal %w(Cake pie sweets), Measured::Unit.new(:pie, aliases: ["Cake", :sweets]).names
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal 10, @unit.conversion_amount
    assert_equal "Cake", @unit.conversion_unit

    unit = Measured::Unit.new(:pie, value: ["5.5", "sweets"])
    assert_equal BigDecimal("5.5"), unit.conversion_amount
    assert_equal "sweets", unit.conversion_unit

    unit = Measured::Unit.new(:pie, value: "1/3 bitter pie")
    assert_equal Rational(1, 3), unit.conversion_amount
    assert_equal "bitter pie", unit.conversion_unit
  end

  test "#initialize raises if the format of the value is incorrect" do
    assert_raises Measured::UnitError do
      Measured::Unit.new(:pie, value: "hello")
    end

    assert_raises Measured::UnitError do
      Measured::Unit.new(:pie, value: "123456")
    end
  end

  test "#to_s returns an expected string" do
    assert_equal "pie", Measured::Unit.new(:pie).to_s
    assert_equal "pie (1/2 sweet)", Measured::Unit.new(:pie, aliases: ["cake"], value: "0.5 sweet").to_s
  end

  test "#to_s can drop the conversion amount" do
    assert_equal "pie", Measured::Unit.new(:pie).to_s(with_conversion_string: false)
  end

  test "#inspect returns an expected string" do
    assert_equal "#<Measured::Unit: pie>", Measured::Unit.new(:pie).inspect
    assert_equal "#<Measured::Unit: pie (cake, semi-sweet)>", Measured::Unit.new(:pie, aliases: ["cake", "semi-sweet"]).inspect
    assert_equal "#<Measured::Unit: pie 1/2 sweet>", Measured::Unit.new(:pie, value: "1/2 sweet").inspect
    assert_equal "#<Measured::Unit: pie (cake) 1/2 sweet>", Measured::Unit.new(:pie, aliases: ["cake"], value: "1/2 sweet").inspect
  end

  test "includes Comparable mixin" do
    assert Measured::Unit.ancestors.include?(Comparable)
  end

  test "#<=> compares non-Unit classes against name" do
    assert_equal 1, @unit <=> "Pap"
    assert_equal (-1), @unit <=> "Pop"
  end

  test "#<=> is 0 for Unit instances that should be equivalent" do
    assert_equal 0, @unit <=> Measured::Unit.new(:Pie, value: "10 cake")
    assert_equal 0, @unit <=> Measured::Unit.new("Pie", value: "10 cake")
    assert_equal 0, @unit <=> Measured::Unit.new("Pie", value: [10, :cake])
  end

  test "#<=> is -1 for units with names that come after Pie lexicographically" do
    assert_equal (-1), @unit <=> Measured::Unit.new(:Pigs, value: "10 bacon")
    assert_equal (-1), @unit <=> Measured::Unit.new("Pig", aliases: %w(Pigs), value: "10 bacon")
  end

  test "#<=> compares #conversion_amount when unit names the same" do
    assert_equal (-1), @unit <=> Measured::Unit.new(:Pie, value: [11, :pancake])
    assert_equal 0, @unit <=> Measured::Unit.new(:Pie, value: [10, :foo])
    assert_equal 1, @unit <=> Measured::Unit.new(:Pie, value: [9, :pancake])
  end

  test "#inverse_conversion_amount returns 1/amount" do
    assert_equal Rational(1, 10), @unit.inverse_conversion_amount
  end

  test "#inverse_conversion_amount handles nil for base unit" do
    assert_nil Measured::Unit.new(:pie).inverse_conversion_amount
  end
end

class Measured::FunctionalUnitTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::Unit.new(:Pie, value: [
      {
        forward: ->(x) { x * Rational(10, 1) },
        backward: ->(x) { x * Rational(1, 10) },
        description: "10 Cake",
      },
      'Cake'
    ])
  end

  test "#initialize sets conversion_unit" do
    assert_equal "Cake", @unit.conversion_unit
  end

  test "#conversion_amount is a Proc" do
    assert_instance_of Proc, @unit.conversion_amount
    assert_equal Rational(10, 1), @unit.conversion_amount.call(1)
  end

  test "#inverse_conversion_amount is a Proc" do
    assert_instance_of Proc, @unit.inverse_conversion_amount
    assert_equal Rational(1, 10), @unit.inverse_conversion_amount.call(1)
  end

  test "#functional? returns true" do
    assert_predicate @unit, :functional?
  end

  test "#functional? returns false for static units" do
    refute_predicate Measured::Unit.new(:Pie, value: "10 Cake"), :functional?
  end

  test "#to_s returns name with description when provided" do
    unit = Measured::Unit.new(:Pie, value: [
      { forward: ->(x) { x * 10 }, backward: ->(x) { x / 10 }, description: "10 Cake" },
      'Cake'
    ])
    assert_equal "Pie (10 Cake)", unit.to_s
  end

  test "#to_s includes description" do
    assert_equal "Pie (10 Cake)", @unit.to_s
  end

  test "#with preserves functional conversion" do
    new_unit = @unit.with(unit_system: :fake)
    assert_instance_of Proc, new_unit.conversion_amount
    assert_equal Rational(10, 1), new_unit.conversion_amount.call(1)
    assert_equal :fake, new_unit.unit_system
  end

  test "#<=> compares functional units by evaluating at 1" do
    assert_equal 0, @unit <=> Measured::Unit.new(:Pie, value: [10, :foo])
    assert_equal(-1, @unit <=> Measured::Unit.new(:Pie, value: [11, :foo]))
    assert_equal 1, @unit <=> Measured::Unit.new(:Pie, value: [9, :foo])
  end

  test "#functional? returns false for base units with no value" do
    refute_predicate Measured::Unit.new(:Pie), :functional?
  end

  test "#inspect includes description when provided" do
    unit = Measured::Unit.new(:Pie, aliases: ["Tart"], value: [
      { forward: ->(x) { x * 10 }, backward: ->(x) { x / 10 }, description: "10 Cake" },
      'Cake'
    ])
    assert_equal "#<Measured::Unit: Pie (Tart) 10 Cake>", unit.inspect
  end

  test "#inspect includes description" do
    assert_equal "#<Measured::Unit: Pie 10 Cake>", @unit.inspect
  end

  test "#to_s with_conversion_string: false returns just name for functional units" do
    assert_equal "Pie", @unit.to_s(with_conversion_string: false)
  end

  test "#initialize raises KeyError when :forward is missing" do
    assert_raises KeyError do
      Measured::Unit.new(:Pie, value: [{ backward: ->(x) { x } }, 'Cake'])
    end
  end

  test "#initialize raises KeyError when :backward is missing" do
    assert_raises KeyError do
      Measured::Unit.new(:Pie, value: [{ forward: ->(x) { x } }, 'Cake'])
    end
  end

  test "#with with explicit value override replaces functional conversion" do
    new_unit = @unit.with(value: "5 Cake")
    refute_predicate new_unit, :functional?
    assert_equal Rational(5, 1), new_unit.conversion_amount
  end

  test "#inverse_conversion_amount stores the backward proc" do
    assert_instance_of Proc, @unit.inverse_conversion_amount
    assert_equal Rational(1, 10), @unit.inverse_conversion_amount.call(1)
    assert_equal Rational(5, 10), @unit.inverse_conversion_amount.call(5)
  end

  test "#inverse_conversion_amount is distinct from conversion_amount" do
    unit = Measured::Unit.new(:K, value: [
      { forward: ->(k) { k - BigDecimal("273.15") }, backward: ->(c) { c + BigDecimal("273.15") }, description: "celsius + 273.15" },
      "C"
    ])
    assert_equal BigDecimal("-272.15"), unit.conversion_amount.call(1)
    assert_equal BigDecimal("274.15"), unit.inverse_conversion_amount.call(1)
  end

  test "#<=> compares two functional units with different procs" do
    small = Measured::Unit.new(:Pie, value: [
      { forward: ->(x) { x * Rational(2, 1) }, backward: ->(x) { x * Rational(1, 2) }, description: "2 Cake" },
      "Cake"
    ])
    large = Measured::Unit.new(:Pie, value: [
      { forward: ->(x) { x * Rational(100, 1) }, backward: ->(x) { x * Rational(1, 100) }, description: "100 Cake" },
      "Cake"
    ])
    assert_equal(-1, small <=> large)
    assert_equal 1, large <=> small
    assert_equal 0, small <=> small
  end
end
