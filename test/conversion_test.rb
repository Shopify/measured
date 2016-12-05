require "test_helper"

class Measured::ConversionTest < ActiveSupport::TestCase
  setup do
    @base = Measured::Unit.new(:m)
    @units = [
      Measured::Unit.new(:in, aliases: [:inch], value: "0.0254 m"),
      Measured::Unit.new(:ft, aliases: [:feet, :foot], value: "0.3048 m"),
    ]

    @conversion = Measured::Conversion.new(@base, @units)
    @case_sensitive_conversion = Measured::Conversion.new(@base, @units, case_sensitive: true)
  end

  test "#unit_names_with_aliases lists all allowed unit names" do
    assert_equal ["feet", "foot", "ft", "in", "inch", "m"], @conversion.unit_names_with_aliases
  end

  test "#unit_names lists all base unit names without aliases" do
    assert_equal ["ft", "in", "m"], @conversion.unit_names
  end

  test "#unit? checks if the unit is part of the units but not aliases" do
    assert @conversion.unit?(:in)
    assert @conversion.unit?("m")
    assert @conversion.unit?("M")
    refute @conversion.unit?("inch")
    refute @conversion.unit?(:yard)
  end

  test "#unit? takes into account case_sensitive flag" do
    assert @case_sensitive_conversion.unit?(:in)
    assert @case_sensitive_conversion.unit?("m")
    refute @case_sensitive_conversion.unit?("M")
    refute @case_sensitive_conversion.unit?("inch")
  end

  test "#unit? with blank and nil arguments" do
    refute @conversion.unit?("")
    refute @conversion.unit?(nil)
  end

  test "#unit_or_alias? checks if the unit is part of the units or aliases" do
    assert @conversion.unit_or_alias?(:inch)
    assert @conversion.unit_or_alias?("m")
    assert @conversion.unit_or_alias?(:IN)
    assert @conversion.unit_or_alias?("in")
    refute @conversion.unit_or_alias?(:yard)
  end

  test "#unit_or_alias? takes into account case_sensitive flag" do
    assert @case_sensitive_conversion.unit_or_alias?(:inch)
    assert @case_sensitive_conversion.unit_or_alias?("m")
    refute @case_sensitive_conversion.unit_or_alias?(:M)
    refute @case_sensitive_conversion.unit_or_alias?("IN")
  end

  test "#unit_or_alias? with blank and nil arguments" do
    refute @conversion.unit_or_alias?("")
    refute @conversion.unit_or_alias?(nil)
  end

  test "#to_unit_name converts a unit name to its base unit" do
    assert_equal "fireball", Magic.conversion.to_unit_name("fire")
  end

  test "#to_unit_name does not care about string or symbol" do
    assert_equal "fireball", Magic.conversion.to_unit_name(:fire)
  end

  test "#to_unit_name passes through if already base unit name" do
    assert_equal "fireball", Magic.conversion.to_unit_name("fireball")
  end

  test "#to_unit_name raises if not found" do
    assert_raises Measured::UnitError do
      Magic.conversion.to_unit_name("thunder")
    end
  end

  test "#convert raises if either unit is not found" do
    assert_raises Measured::UnitError do
      Magic.conversion.convert(1, from: "fire", to: "doesnt_exist")
    end

    assert_raises Measured::UnitError do
      Magic.conversion.convert(1, from: "doesnt_exist", to: "fire")
    end
  end

  test "#convert converts betwen two known units" do
    assert_equal BigDecimal("3"), @conversion.convert(BigDecimal("36"), from: "in", to: "ft")
    assert_equal BigDecimal("18"), @conversion.convert(BigDecimal("1.5"), from: "ft", to: "in")
  end

  test "#convert handles the same unit" do
    assert_equal BigDecimal("2"), @conversion.convert(BigDecimal("2"), from: "in", to: "in")
  end

  test "#conversion_table returns expected nested hashes with BigDecimal conversion factors in a tiny data set" do
    conversion = Measured::Conversion.new(
      Measured::Unit.new(:m),
      [Measured::Unit.new(:cm, value: "0.01 m")]
    )

    expected = {
      "m"  => {
        "m"  => BigDecimal("1"),
        "cm" => BigDecimal("100")
      },
      "cm" => {
        "cm" => BigDecimal("1"),
        "m"  => BigDecimal("0.01")
      }
    }

    assert_equal expected, conversion.conversion_table
  end

  test "#conversion_table returns expected nested hashes with BigDecimal conversion factors" do
    conversion = Measured::Conversion.new(
      Measured::Unit.new(:m),
      [Measured::Unit.new(:cm, value: "0.01 m"), Measured::Unit.new(:mm, value: "0.001 m")]
    )

    expected = {
      "m"  => {
        "m"  => BigDecimal("1"),
        "cm" => BigDecimal("100"),
        "mm" => BigDecimal("1000")
      },
      "cm" => {
        "cm" => BigDecimal("1"),
        "m"  => BigDecimal("0.01"),
        "mm" => BigDecimal("10")
      },
      "mm" => {
        "mm" => BigDecimal("1"),
        "m"  => BigDecimal("0.001"),
        "cm" => BigDecimal("0.1")
      }
    }

    assert_equal expected, conversion.conversion_table
  end

  test "#conversion_table returns expected nested hashes with BigDecimal conversion factors in an indrect path" do
    conversion = Measured::Conversion.new(
      Measured::Unit.new(:mm),
      [
        Measured::Unit.new(:cm, value: "10 mm"),
        Measured::Unit.new(:dm, value: "10 cm"),
        Measured::Unit.new(:m, value: "10 dm"),
      ]
    )

    expected = {
      "m"  => {
        "m"  => BigDecimal("1"),
        "cm" => BigDecimal("100"),
        "dm" => BigDecimal("10"),
        "mm" => BigDecimal("1000")
      },
      "cm" => {
        "cm" => BigDecimal("1"),
        "dm" => BigDecimal("0.1"),
        "m"  => BigDecimal("0.01"),
        "mm" => BigDecimal("10")
      },
      "dm" => {
        "dm" => BigDecimal("1"),
        "cm" => BigDecimal("10"),
        "m"  => BigDecimal("0.1"),
        "mm" => BigDecimal("100")
      },
      "mm" => {
        "mm" => BigDecimal("1"),
        "m"  => BigDecimal("0.001"),
        "dm"  => BigDecimal("0.01"),
        "cm" => BigDecimal("0.1")
      }
    }

    assert_equal expected, conversion.conversion_table
  end

end
