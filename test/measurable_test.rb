require "test_helper"

class Measured::MeasurableTest < ActiveSupport::TestCase

  setup do
    @arcane = Magic.unit_system.unit_for!(:arcane)
    @fireball = Magic.unit_system.unit_for!(:fireball)
    @magic_missile = Magic.unit_system.unit_for!(:magic_missile)
    @magic = Magic.new(10, @magic_missile)
  end

  test "#initialize requires two params, the amount and the unit" do
    assert_nothing_raised do
      Magic.new(1, "fireball")
    end

    assert_raises ArgumentError do
      Magic.new(1)
    end
  end

  test "#initialize converts unit string and symbol to Unit instance" do
    assert_equal @arcane, Magic.new(1, "arcane").unit
    assert_equal @arcane, Magic.new(1, :arcane).unit
  end

  test "#initialize raises if it is an unknown unit" do
    assert_raises Measured::UnitError do
      Magic.new(1, "slash")
    end
  end

  test "#initialize keeps Rationals, BigDecimals, and Integers as-is" do
    assert_equal 10, Magic.new(10, :fire).value
    assert_equal Rational(1, 3), Magic.new(Rational(1, 3), :fire).value
    assert_equal BigDecimal("123.887788"), Magic.new(BigDecimal("123.887788"), :fire).value
  end

  test "#initialize converts floats and strings to BigDecimal and does not round large numbers" do
    assert_equal BigDecimal(9.1234572342342, 14), Magic.new(9.1234572342342, :fire).value
    assert_equal BigDecimal("9.1234572342342"), Magic.new("9.1234572342342", :fire).value
  end

  test "#initialize converts to the base unit" do
    assert_equal @fireball, Magic.new(1, :fire).unit
  end

  test "#initialize raises an expected error when initializing with nil value" do
    exception = assert_raises(Measured::UnitError) do
      Magic.new(nil, :fire)
    end
    assert_equal "Unit value cannot be blank", exception.message
  end

  test "#initialize raises an expected error when initializing with nil unit" do
    exception = assert_raises(Measured::UnitError) do
      Magic.new(1, nil)
    end
    assert_equal "Unit '' does not exist", exception.message
  end

  test "#initialize raises an expected error when initializing with empty string value" do
    exception = assert_raises(Measured::UnitError) do
      Magic.new("", :fire)
    end
    assert_equal "Unit value cannot be blank", exception.message
  end

  test "#initialize raises an expected error when initializing with empty string unit" do
    exception = assert_raises(Measured::UnitError) do
      Magic.new(1, "")
    end
    assert_equal "Unit '' does not exist", exception.message
  end

  test "#unit allows you to read the unit" do
    assert_equal @magic_missile, @magic.unit
  end

  test "#value allows you to read the numeric value" do
    assert_equal 10, @magic.value
  end

  test ".unit_system is set and cached" do
    unit_system = CaseSensitiveMagic.unit_system

    assert_instance_of Measured::UnitSystem, unit_system
    assert_equal unit_system.__id__, CaseSensitiveMagic.unit_system.__id__
  end

  test ".unit_names returns just the base unit names" do
    assert_equal %w(arcane fireball ice magic_missile ultima), Magic.unit_names
  end

  test ".unit_names_with_aliases returns all units" do
    assert_equal(
      %w(arcane fire fireball fireballs ice magic_missile magic_missiles ultima),
      Magic.unit_names_with_aliases
    )
  end

  test ".unit_or_alias? looks at the list of units and aliases" do
    assert Magic.unit_or_alias?("fire")
    assert Magic.unit_or_alias?("fireball")
    assert Magic.unit_or_alias?(:ice)
    refute Magic.unit_or_alias?("junk")
  end

  test ".name looks at the class name" do
    module Example
      VeryComplexThing = Measured.build { unit :foo }
    end

    assert_equal "magic", Magic.name
    assert_equal "very complex thing", Example::VeryComplexThing.name
  end

  test "#convert_to raises on an invalid unit" do
    assert_raises Measured::UnitError do
      @magic.convert_to(Measured::Unit.new(:punch))
    end
  end

  test "#convert_to returns a new object of the same type in the new unit" do
    converted = @magic.convert_to(@arcane)

    assert_equal converted, @magic
    refute_equal converted.object_id, @magic.object_id
    assert_equal BigDecimal(10), @magic.value
    assert_equal @magic_missile, @magic.unit
    assert_equal BigDecimal(1), converted.value
    assert_equal @arcane, converted.unit
  end

  test "#convert_to from and to the same unit returns the same object" do
    converted = @magic.convert_to(@magic.unit)
    assert_equal converted.object_id, @magic.object_id
  end

  test "#to_s outputs the number and the unit" do
    assert_equal "10 fireball (2/3 magic_missile)", Magic.new(10, :fire).to_s
    assert_equal "1.234 magic_missile", Magic.new("1.234", :magic_missile).to_s
  end

  test "#inspect shows the number and the unit" do
    assert_equal "#<Magic: 10 fireball (2/3 magic_missile)>", Magic.new(10, :fire).inspect
    assert_equal "#<Magic: 1.234 magic_missile>", Magic.new(1.234, :magic_missile).inspect
  end

  test "#zero? always returns false" do
    refute_predicate Magic.new(0, :fire), :zero?
    refute_predicate Magic.new(0.0, :fire), :zero?
    refute_predicate Magic.new("0.0", :fire), :zero?
  end

  test "#<=> compares regardless of the unit" do
    assert_equal -1, @magic <=> Magic.new(20, :fire)
    assert_equal 1, @magic <=> Magic.new(9, :magic_missile)
    assert_equal 0, @magic <=> Magic.new(Rational(30, 2), :fire)
    assert_equal -1, @magic <=> Magic.new(11, :magic_missile)
  end

  test "#<=> doesn't compare against zero" do
    assert_nil @magic <=> 0
    assert_nil @magic <=> BigDecimal.new(0)
    assert_nil @magic <=> 0.00
  end

  test "#== should be the same if the classes, unit, and amount match" do
    assert_equal @magic, @magic
    assert_equal Magic.new(10, :magic_missile), Magic.new("10", "magic_missile")
    assert_equal Magic.new(1, :arcane), Magic.new(10, :magic_missile)
    refute_equal Magic.new(1, :arcane), Magic.new(10.1, :magic_missile)
  end

  test "#== should be the same if the classes and amount match but the unit does not so they convert" do
    assert_equal Magic.new(2, :magic_missile), Magic.new("1", "ice")
  end

  test "#== doesn't compare against zero" do
    arcane_zero = Magic.new(0, :arcane)
    refute_equal arcane_zero, 0
    refute_equal arcane_zero, BigDecimal.new(0)
    refute_equal arcane_zero, 0.0
  end

  test "#> and #< should compare measurements" do
    assert Magic.new(10, :magic_missile) < Magic.new(20, :magic_missile)
    refute Magic.new(10, :magic_missile) > Magic.new(20, :magic_missile)
  end

  test "#> and #< should compare measurements of different units" do
    assert Magic.new(10, :magic_missile) < Magic.new(100, :ice)
    refute Magic.new(10, :magic_missile) > Magic.new(100, :ice)
  end

  test "#> and #< should not compare against zero" do
    assert_raises(ArgumentError) { @magic > 0 }
    assert_raises(ArgumentError) { @magic > BigDecimal.new(0) }
    assert_raises(ArgumentError) { @magic > 0.00 }
    assert_raises(ArgumentError) { @magic < 0 }
    assert_raises(ArgumentError) { @magic < BigDecimal.new(0) }
    assert_raises(ArgumentError) { @magic < 0.00 }
  end

end
