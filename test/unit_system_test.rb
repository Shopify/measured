# frozen_string_literal: true
require "test_helper"

class Measured::UnitSystemTest < Minitest::Test
  setup do
    @unit_fireball = Magic.unit_system.unit_for!(:fireball)

    @unit_m = Measured::Unit.new(:m)
    @unit_in = Measured::Unit.new(:in, aliases: [:Inch], value: "0.0254 m")
    @unit_ft = Measured::Unit.new(:ft, aliases: %w(Feet Foot), value: "0.3048 m")
    @conversion = Measured::UnitSystem.new([@unit_m, @unit_in, @unit_ft])
  end

  test "#unit_names_with_aliases lists all allowed unit names" do
    assert_equal %w(Feet Foot Inch ft in m), @conversion.unit_names_with_aliases
  end

  test "#unit_names lists all unit names without aliases" do
    assert_equal %w(ft in m), @conversion.unit_names
  end

  test "#unit? checks if the unit is part of the units but not aliases" do
    assert @conversion.unit?(:in)
    assert @conversion.unit?("m")
    refute @conversion.unit?("M")
    refute @conversion.unit?("inch")
    refute @conversion.unit?(:yard)
  end

  test "#unit? with blank and nil arguments" do
    refute @conversion.unit?("")
    refute @conversion.unit?(nil)
  end

  test "#unit_or_alias? checks if the unit is part of the units or aliases" do
    assert @conversion.unit_or_alias?(:Inch)
    assert @conversion.unit_or_alias?("m")
    assert @conversion.unit_or_alias?("in")
    refute @conversion.unit_or_alias?(:inch)
    refute @conversion.unit_or_alias?(:IN)
    refute @conversion.unit_or_alias?(:yard)
  end

  test "#unit_or_alias? with blank and nil arguments" do
    refute @conversion.unit_or_alias?("")
    refute @conversion.unit_or_alias?(nil)
  end

  test "#unit_for converts a unit name to its base unit" do
    assert_equal @unit_fireball, Magic.unit_system.unit_for("fire")
  end

  test "#unit_for does not care about string or symbol" do
    assert_equal @unit_fireball, Magic.unit_system.unit_for(:fire)
  end

  test "#unit_for passes through if already base unit name" do
    assert_equal @unit_fireball, Magic.unit_system.unit_for("fireball")
  end

  test "#unit_for returns nil if not found" do
    assert_nil Magic.unit_system.unit_for("thunder")
  end

  test "#unit_for! converts a unit name to its base unit" do
    assert_equal @unit_fireball, Magic.unit_system.unit_for!("fire")
  end

  test "#unit_for! does not care about string or symbol" do
    assert_equal @unit_fireball, Magic.unit_system.unit_for!(:fire)
  end

  test "#unit_for! passes through if already base unit name" do
    assert_equal @unit_fireball, Magic.unit_system.unit_for!("fireball")
  end

  test "#unit_for! raises if not found" do
    assert_raises_with_message(Measured::UnitError, "Unit 'thunder' does not exist") do
      Magic.unit_system.unit_for!("thunder")
    end
  end

  test "#convert raises if either unit is not found" do
    unit_bad = Measured::Unit.new(:doesnt_exist)

    assert_raises Measured::UnitError do
      Magic.unit_system.convert(1, from: @unit_fireball, to: unit_bad)
    end

    assert_raises Measured::UnitError do
      Magic.unit_system.convert(1, from: unit_bad, to: @unit_fireball)
    end
  end

  test "#convert converts between two known units" do
    assert_equal 3, @conversion.convert(36, from: @unit_in, to: @unit_ft)
    assert_equal 18, @conversion.convert(Rational(3, 2), from: @unit_ft, to: @unit_in)
  end

  test "#convert handles the same unit" do
    assert_equal 2, @conversion.convert(2, from: @unit_in, to: @unit_in)
  end

  test "#update_cache calls the builder" do
    Measured::ConversionTableBuilder.any_instance.expects(:update_cache)
    @conversion.update_cache
  end

  test "#cached? calls the builder and is false" do
    refute_predicate @conversion, :cached?
  end

  test "#cached? calls the builder and is true" do
    conversion = Measured::UnitSystem.new([@unit_m, @unit_in, @unit_ft], cache: { class: AlwaysTrueCache })
    assert_predicate conversion, :cached?
  end
end
