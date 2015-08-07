require "test_helper"

class Measured::ConversionTest < ActiveSupport::TestCase
  setup do
    @conversion = Measured::Conversion.new
  end

  test "#base sets the base unit" do
    @conversion.set_base :m, aliases: [:metre]
    assert_equal ["m", "metre"], @conversion.base_unit.names
  end

  test "#base doesn't allow a second base to be added" do
    @conversion.set_base :m, aliases: [:metre]

    assert_raises Measured::UnitError do
      @conversion.set_base :in
    end
  end

  test "#add adds a new unit" do
    @conversion.set_base :m
    @conversion.add :in, aliases: [:inch], value: "0.0254 meter"

    assert_equal 2, @conversion.units.count
  end

  test "#add cannot add duplicate unit names" do
    @conversion.set_base :m
    @conversion.add :in, aliases: [:inch], value: "0.0254 meter"

    assert_raises Measured::UnitError do
      @conversion.add :in, aliases: [:thing], value: "123 m"
    end

    assert_raises Measured::UnitError do
      @conversion.add :inch, value: "123 m"
    end
  end

  test "#add does not allow you to add a unit before the base" do
    assert_raises Measured::UnitError do
      @conversion.add :in, aliases: [:inch], value: "0.0254 meter"
    end
  end

  test "#unit_names_with_aliases lists all allowed unit names" do
    @conversion.set_base :m
    @conversion.add :in, aliases: [:inch], value: "0.0254 meter"
    @conversion.add :ft, aliases: [:feet, :foot], value: "0.3048 meter"

    assert_equal ["feet", "foot", "ft", "in", "inch", "m"], @conversion.unit_names_with_aliases
  end

  test "#unit_names lists all base unit names without aliases" do
    @conversion.set_base :m
    @conversion.add :in, aliases: [:inch], value: "0.0254 meter"
    @conversion.add :ft, aliases: [:feet, :foot], value: "0.3048 meter"

    assert_equal ["ft", "in", "m"], @conversion.unit_names
  end

  test "#unit? checks if the unit is part of the units and aliases" do
    @conversion.set_base :m
    @conversion.add :inch, aliases: [:in], value: "0.0254 meter"

    assert @conversion.unit?(:inch)
    assert @conversion.unit?("m")
    assert @conversion.unit?("M")
    refute @conversion.unit?("in")
    refute @conversion.unit?(:yard)
  end

  test "#unit? takes into account case_sensitive flag" do
    @conversion.set_base :m, case_sensitive: true
    @conversion.add :inch, aliases: [:in], value: "0.0254 meter", case_sensitive: true

    assert @conversion.unit?(:inch)
    assert @conversion.unit?("m")
    refute @conversion.unit?("M")
    refute @conversion.unit?("in")
  end

  test "#unit_or_alias? checks if the unit is part of the units but not aliases" do
    @conversion.set_base :m
    @conversion.add :inch, aliases: [:in], value: "0.0254 meter"

    assert @conversion.unit_or_alias?(:inch)
    assert @conversion.unit_or_alias?("m")
    assert @conversion.unit_or_alias?(:IN)
    assert @conversion.unit_or_alias?("in")
    refute @conversion.unit_or_alias?(:yard)
  end

  test "#unit_or_alias? takes into account case_sensitive flag" do
    @conversion.set_base :m, case_sensitive: true
    @conversion.add :inch, aliases: [:in], value: "0.0254 meter", case_sensitive: true

    assert @conversion.unit_or_alias?(:inch)
    assert @conversion.unit_or_alias?("m")
    refute @conversion.unit_or_alias?(:M)
    refute @conversion.unit_or_alias?("IN")
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
    @conversion.set_base :m
    @conversion.add :cm, value: "0.01 m"

    assert_equal BigDecimal("10"), @conversion.convert(BigDecimal("1000"), from: "cm", to: "m")
    assert_equal BigDecimal("250"), @conversion.convert(BigDecimal("2.5"), from: "m", to: "cm")
  end

  test "#convert handles the same unit" do
    @conversion.set_base :m
    @conversion.add :cm, value: "0.01 m"

    assert_equal BigDecimal("2"), @conversion.convert(BigDecimal("2"), from: "cm", to: "cm")
  end

  test "#conversion_table returns expected nested hashes with BigDecimal conversion factors in a tiny data set" do
    @conversion.set_base :m
    @conversion.add :cm, value: "0.01 m"

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

    assert_equal expected, @conversion.conversion_table
  end

  test "#conversion_table returns expected nested hashes with BigDecimal conversion factors" do
    @conversion.set_base :m
    @conversion.add :cm, value: "0.01 m"
    @conversion.add :mm, value: "0.001 m"

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

    assert_equal expected, @conversion.conversion_table
  end

  test "#conversion_table returns expected nested hashes with BigDecimal conversion factors in an indrect path" do
    @conversion.set_base :mm
    @conversion.add :cm, value: "10 mm"
    @conversion.add :dm, value: "10 cm"
    @conversion.add :m, value: "10 dm"

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

    assert_equal expected, @conversion.conversion_table
  end

end
