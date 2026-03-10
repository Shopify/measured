# frozen_string_literal: true

require "test_helper"

class Measured::TemperatureTest < ActiveSupport::TestCase
  test ".unit_names should be the list of base unit names" do
    assert_equal %w(C F K), Measured::Temperature.unit_names
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
    assert_exact_conversion Measured::Temperature, "100 C", "373.15 K"
  end

  test ".convert_to from C to F" do
    assert_exact_conversion Measured::Temperature, "0 C", "32 F"
    assert_exact_conversion Measured::Temperature, "100 C", "212 F"
    assert_exact_conversion Measured::Temperature, "45 C", "113 F"
  end

  test ".convert_to from F to C" do
    assert_exact_conversion Measured::Temperature, "32 F", "0 C"
    assert_exact_conversion Measured::Temperature, "212 F", "100 C"
    assert_exact_conversion Measured::Temperature, "113 F", "45 C"
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

  test "identity conversion" do
    temp = Measured::Temperature.new(100, :C)
    assert_equal temp, temp.convert_to(:C)
  end

  test "arithmetic works" do
    a = Measured::Temperature.new(10, :C)
    b = Measured::Temperature.new(20, :C)
    assert_equal Measured::Temperature.new(30, :C), a + b
  end

  test "comparison across units" do
    boiling_c = Measured::Temperature.new(100, :C)
    boiling_f = Measured::Temperature.new(212, :F)
    assert_equal 0, boiling_c <=> boiling_f
  end

  test "aliases resolve correctly" do
    assert_equal Measured::Temperature.new(100, :C), Measured::Temperature.new(100, :celsius)
    assert_equal Measured::Temperature.new(0, :K), Measured::Temperature.new(0, :kelvin)
    assert_equal Measured::Temperature.new(32, :F), Measured::Temperature.new(32, :fahrenheit)
  end

  test ".unit_names_with_aliases includes all aliases" do
    expected = %w(C F K celsius fahrenheit kelvin).sort
    assert_equal expected, Measured::Temperature.unit_names_with_aliases
  end

  test ".parse parses temperature strings" do
    assert_equal Measured::Temperature.new(100, :C), Measured::Temperature.parse("100 C")
    assert_equal Measured::Temperature.new(212, :F), Measured::Temperature.parse("212 F")
    assert_equal Measured::Temperature.new("273.15", :K), Measured::Temperature.parse("273.15 K")
  end

  test ".parse parses negative temperature strings" do
    assert_equal Measured::Temperature.new(-40, :C), Measured::Temperature.parse("-40 C")
    assert_equal Measured::Temperature.new(-40, :F), Measured::Temperature.parse("-40 F")
  end

  test "to_s outputs the number and the unit" do
    assert_equal "100 C", Measured::Temperature.new(100, :C).to_s
    assert_equal "32 F", Measured::Temperature.new(32, :F).to_s
    assert_equal "273.15 K", Measured::Temperature.new("273.15", :K).to_s
  end

  test "negative value conversions" do
    # -40 is the same in both C and F
    assert_exact_conversion Measured::Temperature, "-40 C", "-40 F"
    assert_exact_conversion Measured::Temperature, "-40 F", "-40 C"
  end

  test "subtraction with same unit" do
    a = Measured::Temperature.new(100, :C)
    b = Measured::Temperature.new(30, :C)
    assert_equal Measured::Temperature.new(70, :C), a - b
  end

  test "comparison operators across units" do
    freezing_c = Measured::Temperature.new(0, :C)
    boiling_c = Measured::Temperature.new(100, :C)
    body_f = Measured::Temperature.new("98.6", :F)

    assert boiling_c > body_f
    assert freezing_c < body_f
  end

  test "equality across units" do
    assert_equal Measured::Temperature.new(0, :C), Measured::Temperature.new(32, :F)
    assert_equal Measured::Temperature.new(0, :C), Measured::Temperature.new("273.15", :K)
  end

  test "convert_to returns new object with correct value" do
    temp = Measured::Temperature.new(100, :C)
    converted = temp.convert_to(:F)

    assert_equal Measured::Temperature.new(212, :F), converted
    assert_equal BigDecimal("100"), temp.value
    assert_equal "C", temp.unit.name
  end
end
