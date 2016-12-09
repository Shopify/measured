require "test_helper"

class Measured::UnitTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::Unit.new(:Pie, value: "10 Cake")
    @unit_with_aliases = Measured::Unit.new(:Pie, aliases: ["Cake", "Tart"])
  end

  test "#initialize converts the name to a string" do
    assert_equal "Pie", @unit.name
  end

  test "#initialize converts aliases to strings and makes a list of names which includes the base" do
    assert_equal ["cake", "pie", "sweets"], Measured::Unit.new(:pie, aliases: ["cake", :sweets]).names
  end

  test "#name_eql? true for valid names when case_sensitive: true" do
    assert @unit.name_eql?("Pie", case_sensitive: true)
    refute @unit.name_eql?("pie", case_sensitive: true)
    refute @unit.name_eql?("pastry", case_sensitive: true)
  end

  test "#name_eql? true for valid names when case_sensitive: false" do
    assert @unit.name_eql?("Pie", case_sensitive: false)
    assert @unit.name_eql?("pie", case_sensitive: false)
    refute @unit.name_eql?("pastry", case_sensitive: false)
  end

  test "#name_eql? false with empty string" do
    refute @unit.name_eql?("")
  end

  test "#names_include? is case insensitive when initialized with case_sensitive: false" do
    assert @unit_with_aliases.names_include?("Pie", case_sensitive: false)
    assert @unit_with_aliases.names_include?("Cake", case_sensitive: false)
    assert @unit_with_aliases.names_include?("Tart", case_sensitive: false)
    assert @unit_with_aliases.names_include?("pie", case_sensitive: false)
    assert @unit_with_aliases.names_include?("cake", case_sensitive: false)
    assert @unit_with_aliases.names_include?("tart", case_sensitive: false)
    refute @unit_with_aliases.names_include?("pastry", case_sensitive: false)
  end

  test "#names_include? is case sensitive when initialized with case_sensitive: true" do
    assert @unit_with_aliases.names_include?("Pie", case_sensitive: true)
    assert @unit_with_aliases.names_include?("Cake", case_sensitive: true)
    assert @unit_with_aliases.names_include?("Tart", case_sensitive: true)
    refute @unit_with_aliases.names_include?("pie", case_sensitive: true)
    refute @unit_with_aliases.names_include?("cake", case_sensitive: true)
    refute @unit_with_aliases.names_include?("tart", case_sensitive: true)
    refute @unit_with_aliases.names_include?("pastry", case_sensitive: true)
  end

  test "#names_include? false with empty string" do
    refute @unit_with_aliases.names_include?("")
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal BigDecimal(10), @unit.conversion_amount
    assert_equal "Cake", @unit.conversion_unit

    unit = Measured::Unit.new(:pie, value: "5.5 sweets")
    assert_equal BigDecimal("5.5"), unit.conversion_amount
    assert_equal "sweets", unit.conversion_unit
  end

  test "#initialize raises if the format of the value is incorrect" do
    assert_raises Measured::UnitError do
      Measured::Unit.new(:pie, value: "hello")
    end

    assert_raises Measured::UnitError do
      Measured::Unit.new(:pie, value: "pie is delicious")
    end

    assert_raises Measured::UnitError do
      Measured::Unit.new(:pie, value: "123456")
    end
  end

  test "#to_s returns an expected string" do
    assert_equal "pie", Measured::Unit.new(:pie).to_s
    assert_equal "pie (1/2 sweet)", Measured::Unit.new(:pie, aliases: ["cake"], value: [Rational(1,2), "sweet"]).to_s
  end

  test "#inspect returns an expected string" do
    assert_equal "#<Measured::Unit: pie (pie) >", Measured::Unit.new(:pie).inspect
    assert_equal "#<Measured::Unit: pie (cake, pie) 1/2 sweet>", Measured::Unit.new(:pie, aliases: ["cake"], value: [Rational(1,2), "sweet"]).inspect
  end

  test "includes Comparable mixin" do
    assert Measured::Unit.ancestors.include?(Comparable)
  end

  test "#<=> compares non-Unit classes against name" do
    assert_equal 1, @unit <=> "Pap"
    assert_equal -1, @unit <=> "Pop"
  end

  test "#<=> is 0 for Unit instances that should be equivalent" do
    assert_equal 0, @unit <=> Measured::Unit.new(:Pie, value: "10 cake")
    assert_equal 0, @unit <=> Measured::Unit.new("Pie", value: "10 cake")
    assert_equal 0, @unit <=> Measured::Unit.new("Pie", value: [10, :cake])
  end

  test "#<=> is 1 for " do
    assert_equal 1, @unit <=> Measured::Unit.new(:pies, value: "10 cake")
    assert_equal 1, @unit <=> Measured::Unit.new("pie", aliases: ["pies"], value: "10 cake")
    assert_equal 1, @unit <=> Measured::Unit.new(:pie, value: [11, :cake])
  end

  test "#inverse_conversion_amount returns 1/amount for BigDecimal" do
    assert_equal BigDecimal(1) / 10, @unit.inverse_conversion_amount
  end

  test "#inverse_conversion_amount swaps the numerator and denominator for Rational" do
    unit = Measured::Unit.new(:pie, value: [Rational(3, 7), "cake"])
    assert_equal Rational(7, 3), unit.inverse_conversion_amount
  end
end
