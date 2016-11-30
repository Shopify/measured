require "test_helper"

class Measured::UnitTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::Unit.new(:pie, value: "10 cake")
  end

  test "#initialize converts the name to a string" do
    assert_equal "pie", @unit.name
  end

  test "#initialize converts aliases to strings and makes a list of names which includes the base" do
    assert_equal ["cake", "pie", "sweets"], Measured::Unit.new(:pie, aliases: ["cake", :sweets]).names
  end

  test "#name_eql?" do
    assert @unit.name_eql?("pIe")
    refute @unit.name_eql?("pastry")
  end

  test "#name_eql? with case_sensitive true" do
    assert @unit.name_eql?("pie", case_sensitive: true)
    refute @unit.name_eql?("Pie", case_sensitive: true)
  end

  test "#name_eql? with empty string" do
    assert @unit.name_eql?("pie")
    refute @unit.name_eql?("")
  end

  test "#names_include?" do
    unit = Measured::Unit.new(:pie, aliases:["cake", "tart"])
    assert unit.names_include?("pie")
    assert unit.names_include?("caKe")
    assert unit.names_include?("taRt")
    refute unit.names_include?("pastry")
  end

  test "#names_include? with case_sensitive true" do
    unit = Measured::Unit.new(:pie, aliases:["cake", "tart"])
    assert unit.names_include?("pie", case_sensitive: true)
    assert unit.names_include?("cake", case_sensitive: true)
    refute unit.names_include?("TART", case_sensitive: true)
  end

  test "#names_include? with empty string" do
    unit = Measured::Unit.new(:pie, aliases: ["cake", "tart"])
    assert unit.names_include?("cake")
    refute unit.names_include?("")
  end

  test "#initialize parses out the unit and the number part" do
    assert_equal BigDecimal(10), @unit.conversion_amount
    assert_equal "cake", @unit.conversion_unit

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

  test "#to_s" do
    assert_equal "pie", Measured::Unit.new(:pie).to_s
    assert_equal "pie (1/2 sweet)", Measured::Unit.new(:pie, aliases: ["cake"], value: [Rational(1,2), "sweet"]).to_s
  end

  test "#inspect returns an expected string" do
    assert_equal "#<Measured::Unit: pie (pie) >", Measured::Unit.new(:pie).inspect
    assert_equal "#<Measured::Unit: pie (cake, pie) 1/2 sweet>", Measured::Unit.new(:pie, aliases: ["cake"], value: [Rational(1,2), "sweet"]).inspect
  end

  test "is comparable" do
    assert Measured::Unit.ancestors.include?(Comparable)
  end

  test "#<=> delegates down to name for non Unit comparisons" do
    assert_equal 1, @unit <=> "anything"
  end

  test "#<=> is equal for same values" do
    assert_equal 0, @unit <=> Measured::Unit.new(:pie, value: "10 cake")
    assert_equal 0, @unit <=> Measured::Unit.new("pie", value: "10 cake")
    assert_equal 0, @unit <=> Measured::Unit.new("pie", value: [10, :cake])
  end

  test "#<=> is slightly different" do
    assert_equal 1, @unit <=> Measured::Unit.new(:pies, value: "10 cake")
    assert_equal 1, @unit <=> Measured::Unit.new("pie", aliases: ["pies"], value: "10 cake")
    assert_equal 1, @unit <=> Measured::Unit.new(:pie, value: [11, :cake])
  end

  test "#inverse_conversion_amount returns 1/amount for BigDecimal" do
    assert_equal BigDecimal(1)/BigDecimal(10), @unit.inverse_conversion_amount
  end

  test "#inverse_conversion_amount swaps the numerator and denominator for Rational" do
    unit = Measured::Unit.new(:pie, value: [Rational(3, 7), "cake"])
    assert_equal Rational(7, 3), unit.inverse_conversion_amount
  end
end
