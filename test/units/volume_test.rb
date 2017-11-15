require "test_helper"

class Measured::VolumeTest < ActiveSupport::TestCase
  setup do
    @volume = Measured::Volume.new(1, 'm3')
  end

  test ".unit_names_with_aliases should be the expected list of valid units" do
    expected_units = %w(
      m3
      cubic_meter
      cubic_metre
      cubic_meters
      cubic_metres
      l
      liter
      litre
      liters
      litres
      ft3
      cubic_foot
      cubic_feet
      in3
      cubic_inch
      cubic_inches
      gal
      imp_gal
      imperial_gallon
      imp_gals
      imperial_gallons
      us_gal
      us_gallon
      us_gals
      us_gallons
      qt
      imp_qt
      imperial_quart
      imp_qts
      imperial_quarts
      us_qt
      us_quart
      us_quarts
      pt
      imp_pt
      imperial_pint
      imp_pts
      imperial_pints
      us_pt
      us_pint
      us_pints
      oz
      fl_oz
      imp_fl_oz
      fluid_ounce
      imperial_fluid_ounce
      fluid_ounces
      imperial_fluid_ounces
      us_oz
      us_fl_oz
      us_fluid_ounce
      us_fluid_ounces
    )
    expected_units += Measured::UnitSystemBuilder::SI_PREFIXES.flat_map do |short, long, _|
      ["#{short}l", "#{long}liter", "#{long}litre", "#{long}liters", "#{long}litres"]
    end

    assert_equal expected_units.sort, Measured::Volume.unit_names_with_aliases
  end

  test ".unit_names should be the list of base unit names" do
    expected_units = %w(l m3 ft3 in3 gal us_gal qt us_qt pt us_pt oz us_oz)
    expected_units += Measured::UnitSystemBuilder::SI_PREFIXES.map { |short, _, _| "#{short}l" }
    assert_equal expected_units.sort, Measured::Volume.unit_names 
  end

  test ".name" do
    assert_equal "volume", Measured::Volume.name
  end

  test "Measured::Volume() delegates automatically to .new" do
    assert_equal Measured::Volume.new(1, :ml), Measured::Volume(1, :ml)
    assert_equal Measured::Volume.new(2, :fl_oz), Measured::Volume(2, :fl_oz)
  end

  test ".convert_to from ml to ml" do
    assert_exact_conversion Measured::Volume, "1000 ml", "1000 ml"
  end
end