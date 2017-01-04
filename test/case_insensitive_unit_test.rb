require "test_helper"

class Measured::CaseInsensitiveUnitTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::CaseInsensitiveUnit.new(:Pie, value: "10 Cake")
    @unit_with_aliases = Measured::CaseInsensitiveUnit.new(:Pie, aliases: ["Cake", "Tart"])
  end

  test "#initialize converts the name to a downcased string" do
    assert_equal "pie", @unit.name
  end

  test "#initialize converts aliases to strings and makes a list of sorted, downcased names which includes the base" do
    assert_equal %w(cake pie sweets), Measured::CaseInsensitiveUnit.new(:pie, aliases: ["Cake", :Sweets]).names
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal BigDecimal(10), @unit.conversion_amount
    assert_equal "Cake", @unit.conversion_unit

    unit = Measured::CaseInsensitiveUnit.new(:pie, value: "5.5 sweets")
    assert_equal BigDecimal("5.5"), unit.conversion_amount
    assert_equal "sweets", unit.conversion_unit
  end

  test "#initialize raises if the format of the value is incorrect" do
    assert_raises Measured::UnitError do
      Measured::CaseInsensitiveUnit.new(:pie, value: "hello")
    end

    assert_raises Measured::UnitError do
      Measured::CaseInsensitiveUnit.new(:pie, value: "pie is delicious")
    end

    assert_raises Measured::UnitError do
      Measured::CaseInsensitiveUnit.new(:pie, value: "123456")
    end
  end

  test "#to_s returns an expected string" do
    assert_equal "pie", Measured::CaseInsensitiveUnit.new(:pie).to_s
    assert_equal "pie (1/2 sweet)", Measured::CaseInsensitiveUnit.new(:pie, aliases: ["cake"], value: [Rational(1,2), "sweet"]).to_s
  end

  test "#inspect returns an expected string" do
    assert_equal "#<Measured::Unit: pie (pie) >", Measured::CaseInsensitiveUnit.new(:pie).inspect
    assert_equal "#<Measured::Unit: pie (cake, pie) 1/2 sweet>", Measured::CaseInsensitiveUnit.new(:pie, aliases: ["cake"], value: [Rational(1,2), "sweet"]).inspect
  end

  test "includes Comparable mixin" do
    assert Measured::Unit.ancestors.include?(Comparable)
  end

  test "#<=> compares non-Unit classes against name" do
    assert_equal 1, @unit <=> "pap"
    assert_equal -1, @unit <=> "pop"
  end

  test "#<=> is 0 for Unit instances that should be equivalent" do
    assert_equal 0, @unit <=> Measured::CaseInsensitiveUnit.new(:Pie, value: "10 cake")
    assert_equal 0, @unit <=> Measured::CaseInsensitiveUnit.new("Pie", value: "10 cake")
    assert_equal 0, @unit <=> Measured::CaseInsensitiveUnit.new("Pie", value: [10, :cake])
  end

  test "#<=> is 1 for " do
    assert_equal 1, @unit <=> Measured::CaseInsensitiveUnit.new(:pies, value: "10 cake")
    assert_equal 1, @unit <=> Measured::CaseInsensitiveUnit.new("pie", aliases: ["pies"], value: "10 cake")
    assert_equal 1, @unit <=> Measured::CaseInsensitiveUnit.new(:pie, value: [11, :cake])
  end

  test "#inverse_conversion_amount returns 1/amount for BigDecimal" do
    assert_equal BigDecimal(1) / 10, @unit.inverse_conversion_amount
  end

  test "#inverse_conversion_amount swaps the numerator and denominator for Rational" do
    unit = Measured::CaseInsensitiveUnit.new(:pie, value: [Rational(3, 7), "cake"])
    assert_equal Rational(7, 3), unit.inverse_conversion_amount
  end
end
