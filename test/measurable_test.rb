require "test_helper"

class Measured::MeasurableTest < ActiveSupport::TestCase

  setup do
    @magic = Magic.new(10, :magic_missile)
  end

  test "#initialize requires two params, the amount and the unit" do
    assert_nothing_raised do
      Magic.new(1, "fireball")
    end

    assert_raises ArgumentError do
      Magic.new(1)
    end
  end

  test "#initialize converts unit to string from symbol" do
    magic = Magic.new(1, :arcane)
    assert_equal "arcane", magic.unit
  end

  test "#initialize raises if it is an unknown unit" do
    assert_raises Measured::UnitError do
      Magic.new(1, "slash")
    end
  end

  test "#initialize converts numbers and strings into BigDecimal" do
    assert_equal BigDecimal(1), Magic.new(1, :arcane).value
    assert_equal BigDecimal("2.3"), Magic.new("2.3", :arcane).value
    assert_equal BigDecimal("5"), Magic.new("5", :arcane).value
  end

  test "#initialize converts floats to strings and then to BigDecimal so it does not raise" do
    assert_equal BigDecimal("1.2345"), Magic.new(1.2345, :fire).value
  end

  test "#initialize converts to the base unit name" do
    assert_equal "fireball", Magic.new(1, :fire).unit
  end

  test "#unit allows you to read the unit string" do
    assert_equal "magic_missile", @magic.unit
  end

  test "#value allows you to read the numeric value" do
    assert_equal BigDecimal(10), @magic.value
  end

  test ".conversion is set and cached" do
    conversion = Magic.conversion

    assert_instance_of Measured::Conversion, conversion
    assert_equal conversion, Magic.conversion
  end

  test ".units returns just the base units" do
    assert_equal ["arcane", "fireball", "ice", "magic_missile", "ultima"], Magic.units
  end

  test ".units_with_aliases returns all units" do
    assert_equal ["arcane", "fire", "fireball", "fireballs", "ice", "magic_missile", "magic_missiles", "ultima"], Magic.units_with_aliases
  end

  test ".valid_unit? looks at the list of units and aliases" do
    assert Magic.valid_unit?("fire")
    assert Magic.valid_unit?("fireball")
    assert Magic.valid_unit?(:ice)
    refute Magic.valid_unit?("junk")
  end

  test "#convert_to raises on an invalid unit" do
    assert_raises Measured::UnitError do
      @magic.convert_to(:punch)
    end
  end

  test "#convert_to returns a new object of the same type in the new unit" do
    converted = @magic.convert_to(:arcane)

    refute_equal converted, @magic
    assert_equal BigDecimal(10), @magic.value
    assert_equal "magic_missile", @magic.unit
    assert_equal BigDecimal(1), converted.value
    assert_equal "arcane", converted.unit
  end

  test "#convert_to! replaces the existing object with a new version in the new unit" do
    converted = @magic.convert_to!(:arcane)

    assert_equal converted, @magic
    assert_equal BigDecimal(1), @magic.value
    assert_equal "arcane", @magic.unit
    assert_equal BigDecimal(1), converted.value
    assert_equal "arcane", converted.unit
  end

  test "#to_s outputs the number and the unit" do
    assert_equal "10 fireball", Magic.new(10, :fire).to_s
    assert_equal "1.234 magic_missile", Magic.new("1.234", :magic_missile).to_s
  end

  test "#inspect shows the number and the unit" do
    assert_equal "#<Magic: 0.1E2 fireball>", Magic.new(10, :fire).inspect
    assert_equal "#<Magic: 0.1234E1 magic_missile>", Magic.new(1.234, :magic_missile).inspect
  end

  test "#<=> compares only if the class and unit are the same" do
    assert_nil @magic <=> Magic.new(10, :fire)
    assert_equal 1, @magic <=> Magic.new(9, :magic_missile)
    assert_equal 0, @magic <=> Magic.new(10, :magic_missile)
    assert_equal -1, @magic <=> Magic.new(11, :magic_missile)
  end

  test "#== should be the same if the classes, unit, and amount match" do
    assert @magic == @magic
    assert Magic.new(10, :magic_missile) == Magic.new("10", "magic_missile")
    refute Magic.new(1, :arcane) == Magic.new(10, :magic_missile)
  end

  test "#eql? should be the same if the classes, unit, and amount match" do
    assert @magic == @magic
    assert Magic.new(10, :magic_missile) == Magic.new("10", "magic_missile")
    refute Magic.new(1, :arcane) == Magic.new(10, :magic_missile)
  end

end
