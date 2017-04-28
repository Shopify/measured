require "test_helper"
require "measured/units/length"

class Measured::LengthTest < ActiveSupport::TestCase
  test ".unit_names_with_aliases should be the expected list of valid units" do
    assert_equal(
      %w(
        centimeter centimeters centimetre centimetres cm feet foot ft
        in inch inches m meter meters metre metres millimeter
        millimeters millimetre millimetres mm yard yards yd
      ),
      Measured::Length.unit_names_with_aliases
    )
  end

  test ".unit_names should be the list of base unit names" do
    assert_equal %w(cm ft in m mm yd), Measured::Length.unit_names
  end

  test ".name" do
    assert_equal "length", Measured::Length.name
  end

  test "Measured::Length() delegates automatically to .new" do
    assert_equal Measured::Length.new(1, :in), Measured::Length(1, :in)
    assert_equal Measured::Length.new(200, :mm), Measured::Length(20, :cm)
  end

  test ".convert_to from cm to cm" do
    assert_exact_conversion Measured::Length, "2000 cm", "2000 cm"
  end

  test ".convert_to from cm to ft" do
    assert_conversion Measured::Length, "2000 cm", "0.656167979E2 ft"
  end

  test ".convert_to from cm to in" do
    assert_conversion Measured::Length, "2000 cm", "0.7874015748E3 in"
  end

  test ".convert_to from cm to m" do
    assert_exact_conversion Measured::Length, "2000 cm", "20 m"
  end

  test ".convert_to from cm to mm" do
    assert_exact_conversion Measured::Length, "2000 cm", "20000 mm"
  end

  test ".convert_to from cm to yd" do
    assert_conversion Measured::Length, "2000 cm", "0.2187226596E2 yd"
  end

  test ".convert_to from ft to cm" do
    assert_conversion Measured::Length, "2000 ft", "60960 cm"
  end

  test ".convert_to from ft to ft" do
    assert_exact_conversion Measured::Length, "2000 ft", "2000 ft"
  end

  test ".convert_to from ft to in" do
    assert_exact_conversion Measured::Length, "2000 ft", "24000 in"
  end

  test ".convert_to from ft to m" do
    assert_exact_conversion Measured::Length, "2000 ft", "609.6 m"
  end

  test ".convert_to from ft to mm" do
    assert_conversion Measured::Length, "2000 ft", "609600 mm"
  end

  test ".convert_to from ft to yd" do
    assert_conversion Measured::Length, "2000 ft", "0.666666667E3 yd"
  end

  test ".convert_to from in to cm" do
    assert_conversion Measured::Length, "2000 in", "5080 cm"
  end

  test ".convert_to from in to ft" do
    assert_conversion Measured::Length, "2000 in", "0.166666666666E3 ft"
  end

  test ".convert_to from in to in" do
    assert_exact_conversion Measured::Length, "2000 in", "2000 in"
  end

  test ".convert_to from in to m" do
    assert_conversion Measured::Length, "2000 in", "50.8 m"
  end

  test ".convert_to from in to mm" do
    assert_conversion Measured::Length, "2000 in", "50800 mm"
  end

  test ".convert_to from in to yd" do
    assert_conversion Measured::Length, "2000 in", "0.555555555384E2 yd"
  end

  test ".convert_to from m to cm" do
    assert_conversion Measured::Length, "2000 m", "200000 cm"
  end

  test ".convert_to from m to ft" do
    assert_conversion Measured::Length, "2000 m", "0.656167979E4 ft"
  end

  test ".convert_to from m to in" do
    assert_conversion Measured::Length, "2000 m", "0.7874015748E5 in"
  end

  test ".convert_to from m to m" do
    assert_exact_conversion Measured::Length, "2000 m", "2000 m"
  end

  test ".convert_to from m to mm" do
    assert_exact_conversion Measured::Length, "2000 m", "2000000 mm"
  end

  test ".convert_to from m to yd" do
    assert_conversion Measured::Length, "2000 m", "0.2187226596E4 yd"
  end

  test ".convert_to from mm to cm" do
    assert_exact_conversion Measured::Length, "2000 mm", "200 cm"
  end

  test ".convert_to from mm to ft" do
    assert_conversion Measured::Length, "2000 mm", "0.656167979E1 ft"
  end

  test ".convert_to from mm to in" do
    assert_conversion Measured::Length, "2000 mm", "0.7874015748E2 in"
  end

  test ".convert_to from mm to m" do
    assert_exact_conversion Measured::Length, "2000 mm", "2 m"
  end

  test ".convert_to from mm to mm" do
    assert_exact_conversion Measured::Length, "2000 mm", "2000 mm"
  end

  test ".convert_to from mm to yd" do
    assert_conversion Measured::Length, "2000 mm", "0.2187226596E1 yd"
  end

  test ".convert_to from yd to cm" do
    assert_conversion Measured::Length, "2000 yd", "0.18288E6 cm"
  end

  test ".convert_to from yd to ft" do
    assert_exact_conversion Measured::Length, "2000 yd", "6000 ft"
  end

  test ".convert_to from yd to in" do
    assert_exact_conversion Measured::Length, "2000 yd", "72000 in"
  end

  test ".convert_to from yd to m" do
    assert_conversion Measured::Length, "2000 yd", "1828.8 m"
  end

  test ".convert_to from yd to mm" do
    assert_conversion Measured::Length, "2000 yd", "1828800 mm"
  end

  test ".convert_to from yd to yd" do
    assert_exact_conversion Measured::Length, "2000 yd", "2000 yd"
  end

end
