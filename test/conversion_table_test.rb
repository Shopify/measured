require "test_helper"

class Measured::ConversionTableTest < ActiveSupport::TestCase
  test "#initialize creates a new object with the units" do
    units = [Measured::Unit.new(:test)]

    assert_equal units, Measured::ConversionTable.new(units).units
  end

  test "#to_h should return a hash for the simple case" do
    expected = {
      "test" => {"test" => BigDecimal("1")}
    }

    assert_equal expected, Measured::ConversionTable.new([Measured::Unit.new(:test)]).to_h
  end

  test "#to_h returns expected nested hashes with BigDecimal conversion factors in a tiny data set" do
    conversion_table = Measured::ConversionTable.new([
      Measured::Unit.new(:m),
      Measured::Unit.new(:cm, value: "0.01 m"),
    ]).to_h

    expected = {
      "m" => {
        "m" => BigDecimal("1"),
        "cm" => BigDecimal("100"),
      },
      "cm" => {
        "m" => BigDecimal("0.01"),
        "cm" => BigDecimal("1"),
      }
    }

    assert_equal expected, conversion_table
  end

  test "#to_h returns expected nested hashes with BigDecimal conversion factors" do
    conversion_table = Measured::ConversionTable.new([
      Measured::Unit.new(:m),
      Measured::Unit.new(:cm, value: "0.01 m"),
      Measured::Unit.new(:mm, value: "0.001 m"),
    ]).to_h

    expected = {
      "m" => {
        "m" => BigDecimal("1"),
        "cm" => BigDecimal("100"),
        "mm" => BigDecimal("1000"),
      },
      "cm" => {
        "m" => BigDecimal("0.01"),
        "cm" => BigDecimal("1"),
        "mm" => BigDecimal("10"),
      },
      "mm" => {
        "m" => BigDecimal("0.001"),
        "cm" => BigDecimal("0.1"),
        "mm" => BigDecimal("1"),
      }
    }

    assert_equal expected, conversion_table
  end

  test "#to_h returns expected nested hashes with BigDecimal conversion factors in an indrect path" do
    conversion_table = Measured::ConversionTable.new([
      Measured::Unit.new(:mm),
      Measured::Unit.new(:cm, value: "10 mm"),
      Measured::Unit.new(:dm, value: "10 cm"),
      Measured::Unit.new(:m, value: "10 dm"),
    ]).to_h

    expected = {
      "m" => {
        "m" => BigDecimal("1"),
        "dm" => BigDecimal("10"),
        "cm" => BigDecimal("100"),
        "mm" => BigDecimal("1000"),
      },
      "cm" => {
        "m" => BigDecimal("0.01"),
        "dm" => BigDecimal("0.1"),
        "cm" => BigDecimal("1"),
        "mm" => BigDecimal("10"),
      },
      "dm" => {
        "m" => BigDecimal("0.1"),
        "cm" => BigDecimal("10"),
        "dm" => BigDecimal("1"),
        "mm" => BigDecimal("100"),
      },
      "mm" => {
        "m" => BigDecimal("0.001"),
        "dm" => BigDecimal("0.01"),
        "cm" => BigDecimal("0.1"),
        "mm" => BigDecimal("1"),
      }
    }

    assert_equal expected, conversion_table
  end
end
