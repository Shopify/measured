# frozen_string_literal: true
Measured::Temperature = Measured.build do
  unit :C, aliases: [:c, :celsius]

  unit :K, value: [
    {
      conversion: ->(k) { k - BigDecimal('273.15') },
      reverse_conversion: ->(c) { c + BigDecimal('273.15') },
      description: 'celsius + 273.15'
    }, 'C'], aliases: [:k, :kelvin]

  unit :F, value: [
    {
      conversion: ->(f) { (f-32) * Rational(5,9) },
      reverse_conversion: ->(c) { c * Rational(9,5) + 32 },
      description: '9 * celsius / 5 + 32'
    }, 'C'], aliases: [:f, :farenheit]
end

require "test_helper"

class Measured::TemperatureTest < ActiveSupport::TestCase
  test ".unit_names should be the list of base unit names" do
    expected_units = %w(C F K)
    assert_equal expected_units.sort, Measured::Temperature.unit_names
  end

  test ".name" do
    assert_equal "temperature", Measured::Temperature.name
  end

  test "Measured::Temperature() delegates automatically to .new" do
    assert_equal Measured::Temperature.new(1, :C), Measured::Temperature(1, :C)
  end

  test ".convert_to from C to K" do
    assert_exact_conversion Measured::Temperature, "0 C", "273.15 K"
    assert_exact_conversion Measured::Temperature, "10 C", "283.15 K"
  end

  test ".convert_to from C to F" do
    assert_exact_conversion Measured::Temperature, "45 C", "113 F"
    assert_exact_conversion Measured::Temperature, "0 C", "32 F"
  end

  test ".convert_to from F to C" do
    assert_exact_conversion Measured::Temperature, "113 F", "45 C"
    assert_exact_conversion Measured::Temperature, "32 F", "0 C"
  end

  test ".convert_to from F to K" do
    assert_exact_conversion Measured::Temperature, "32 F", "273.15 K"
  end

  test ".convert_to from K to C" do
    assert_exact_conversion Measured::Temperature, "273.15 K", "0 C"
    assert_exact_conversion Measured::Temperature, "0 K", "-273.15 C"
  end

  test ".convert_to from K to F" do
    assert_exact_conversion Measured::Temperature, "0 K", "-459.67 F"
  end
end
