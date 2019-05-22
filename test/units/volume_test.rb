# frozen_string_literal: true
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
      imperial_fluid_ounce
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
    assert_conversion Measured::Volume, "2000 ml", "2000 ml"
  end

  test ".convert_to from ft3 to ft3" do
    assert_conversion Measured::Volume, "2000 ft3", "2000 ft3"
  end

  test ".convert_to from in3 to in3" do
    assert_conversion Measured::Volume, "2000 in3", "2000 in3"
  end

  test ".convert_to from gal to gal" do
    assert_conversion Measured::Volume, "2000 gal", "2000 gal"
  end

  test ".convert_to from us_gal to us_gal" do
    assert_conversion Measured::Volume, "2000 us_gal", "2000 us_gal"
  end

  test ".convert_to from qt to qt" do
    assert_conversion Measured::Volume, "2000 qt", "2000 qt"
  end

  test ".convert_to from us_qt to us_qt" do
    assert_conversion Measured::Volume, "2000 us_qt", "2000 us_qt"
  end

  test ".convert_to from pt to pt" do
    assert_conversion Measured::Volume, "2000 pt", "2000 pt"
  end

  test ".convert_to from us_pt to us_pt" do
    assert_conversion Measured::Volume, "2000 us_pt", "2000 us_pt"
  end

  test ".convert_to from oz to oz" do
    assert_conversion Measured::Volume, "2000 oz", "2000 oz"
  end

  test ".convert_to from us_oz to us_oz" do
    assert_conversion Measured::Volume, "2000 us_oz", "2000 us_oz"
  end

  test ".convert_to from ml to m3" do
    assert_conversion Measured::Volume, "2000 ml", "0.002 m3"
  end

  test ".convert_to from ml to ft3" do
    assert_conversion Measured::Volume, "2000 ml", "0.07062933344 ft3"
  end

  test ".convert_to from ml to in3" do
    assert_conversion Measured::Volume, "2000 ml", "122.0474881895 in3"
  end

  test ".convert_to from ml to gal" do
    assert_conversion Measured::Volume, "2000 ml", "0.4399384966 gal"
  end

  test ".convert_to from ml to us_gal" do
    assert_conversion Measured::Volume, "2000 ml", "0.5283441 us_gal"
  end

  test ".convert_to from ml to qt" do
    assert_conversion Measured::Volume, "2000 ml", "1.759754 qt"
  end

  test ".convert_to from ml to us_qt" do
    assert_conversion Measured::Volume, "2000 ml", "2.1133774149 us_qt"
  end

  test ".convert_to from ml to pt" do
    assert_conversion Measured::Volume, "2000 ml", "3.519508 pt"
  end

  test ".convert_to from ml to us_pt" do
    assert_conversion Measured::Volume, "2000 ml", "4.2267528377 us_pt"
  end

  test ".convert_to from ml to oz" do
    assert_conversion Measured::Volume, "2000 ml", "70.39016 oz"
  end

  test ".convert_to from ml to us_oz" do
    assert_conversion Measured::Volume, "2000 ml", "67.6280454037 us_oz"
  end

  test ".convert_to from m3 to ft3" do
    assert_conversion Measured::Volume, "2 m3", "70.629333443 ft3"
  end

  test ".convert_to from m3 to in3" do
    assert_conversion Measured::Volume, "2 m3", "122047.488189465 in3"
  end

  test ".convert_to from m3 to gal" do
    assert_conversion Measured::Volume, "2 m3", "439.9384965982 gal"
  end

  test ".convert_to from m3 to us_gal" do
    assert_conversion Measured::Volume, "2 m3", "528.3441047163 us_gal"
  end

  test ".convert_to from m3 to qt" do
    assert_conversion Measured::Volume, "2 m3", "1759.7539863927 qt"
  end

  test ".convert_to from m3 to us_qt" do
    assert_conversion Measured::Volume, "2 m3", "2113.3764188652 us_qt"
  end

  test ".convert_to from m3 to pt" do
    assert_conversion Measured::Volume, "2 m3", "3519.5079727854 pt"
  end

  test ".convert_to from m3 to us_pt" do
    assert_conversion Measured::Volume, "2 m3", "4226.7528377304 us_pt"
  end

  test ".convert_to from m3 to oz" do
    assert_conversion Measured::Volume, "2 m3", "70390.1594557081 oz"
  end

  test ".convert_to from m3 to us_oz" do
    assert_conversion Measured::Volume, "2 m3", "67628.045403686 us_oz"
  end

  test ".convert_to from ft3 to in3" do
    assert_conversion Measured::Volume, "2 ft3", "3456 in3"
  end

  test ".convert_to from ft3 to gal" do
    assert_conversion Measured::Volume, "2 ft3", "12.4576709181 gal"
  end

  test ".convert_to from ft3 to us_gal" do
    assert_conversion Measured::Volume, "2 ft3", "14.961038961 us_gal"
  end

  test ".convert_to from ft3 to qt" do
    assert_conversion Measured::Volume, "2 ft3", "49.8306836723 qt"
  end

  test ".convert_to from ft3 to us_qt" do
    assert_conversion Measured::Volume, "2 ft3", "59.8441558442 us_qt"
  end

  test ".convert_to from ft3 to pt" do
    assert_conversion Measured::Volume, "2 ft3", "99.6613673447 pt"
  end

  test ".convert_to from ft3 to us_pt" do
    assert_conversion Measured::Volume, "2 ft3", "119.6883116883 us_pt"
  end

  test ".convert_to from ft3 to oz" do
    assert_conversion Measured::Volume, "2 ft3", "1993.2273468937 oz"
  end

  test ".convert_to from ft3 to us_oz" do
    assert_conversion Measured::Volume, "2 ft3", "1915.012987013 us_oz"
  end

  test ".convert_to from in3 to gal" do
    assert_conversion Measured::Volume, "2 in3", "0.0072093003 gal"
  end

  test ".convert_to from in3 to us_gal" do
    assert_conversion Measured::Volume, "2 in3", "0.008658008658 us_gal"
  end

  test ".convert_to from in3 to qt" do
    assert_conversion Measured::Volume, "2 in3", "0.0288372012 qt"
  end

  test ".convert_to from in3 to us_qt" do
    assert_conversion Measured::Volume, "2 in3", "0.03463203463 us_qt"
  end

  test ".convert_to from in3 to pt" do
    assert_conversion Measured::Volume, "2 in3", "0.0576744024 pt"
  end

  test ".convert_to from in3 to us_pt" do
    assert_conversion Measured::Volume, "2 in3", "0.06926406926 us_pt"
  end

  test ".convert_to from in3 to oz" do
    assert_conversion Measured::Volume, "2 in3", "1.153488048 oz"
  end

  test ".convert_to from in3 to us_oz" do
    assert_conversion Measured::Volume, "2 in3", "1.1082251082 us_oz"
  end

  test ".convert_to from gal to us_gal" do
    assert_conversion Measured::Volume, "2 gal", "2.401899851 us_gal"
  end

  test ".convert_to from gal to qt" do
    assert_conversion Measured::Volume, "2 gal", "8 qt"
  end

  test ".convert_to from gal to us_qt" do
    assert_conversion Measured::Volume, "2 gal", "9.607599404 us_qt"
  end

  test ".convert_to from gal to pt" do
    assert_conversion Measured::Volume, "2 gal", "16 pt"
  end

  test ".convert_to from gal to us_pt" do
    assert_conversion Measured::Volume, "2 gal", "19.2151988081 us_pt"
  end

  test ".convert_to from gal to oz" do
    assert_conversion Measured::Volume, "2 gal", "320 oz"
  end

  test ".convert_to from gal to us_oz" do
    assert_conversion Measured::Volume, "2 gal", "307.4431809292 us_oz"
  end

  test ".convert_to from us_gal to qt" do
    assert_conversion Measured::Volume, "2 us_gal", "6.661393477 qt"
  end

  test ".convert_to from us_gal to us_qt" do
    assert_conversion Measured::Volume, "2 us_gal", "8 us_qt"
  end

  test ".convert_to from us_gal to pt" do
    assert_conversion Measured::Volume, "2 us_gal", "13.3227869541 pt"
  end

  test ".convert_to from us_gal to us_pt" do
    assert_conversion Measured::Volume, "2 us_gal", "16 us_pt"
  end

  test ".convert_to from us_gal to oz" do
    assert_conversion Measured::Volume, "2 us_gal", "266.4557390813 oz"
  end

  test ".convert_to from us_gal to us_oz" do
    assert_conversion Measured::Volume, "2 us_gal", "256 us_oz"
  end

  test ".convert_to from qt to us_qt" do
    assert_conversion Measured::Volume, "2 qt", "2.401899851 us_qt"
  end

  test ".convert_to from qt to pt" do
    assert_conversion Measured::Volume, "2 qt", "4 pt"
  end

  test ".convert_to from qt to us_pt" do
    assert_conversion Measured::Volume, "2 qt", "4.803799702 us_pt"
  end

  test ".convert_to from qt to oz" do
    assert_conversion Measured::Volume, "2 qt", "80 oz"
  end

  test ".convert_to from qt to us_oz" do
    assert_conversion Measured::Volume, "2 qt", "76.8607952323 us_oz"
  end

  test ".convert_to from us_qt to pt" do
    assert_conversion Measured::Volume, "2 us_qt", "3.3306967385 pt"
  end

  test ".convert_to from us_qt to us_pt" do
    assert_conversion Measured::Volume, "2 us_qt", "4 us_pt"
  end

  test ".convert_to from us_qt to oz" do
    assert_conversion Measured::Volume, "2 us_qt", "66.6139347703 oz"
  end

  test ".convert_to from us_qt to us_oz" do
    assert_conversion Measured::Volume, "2 us_qt", "64 us_oz"
  end

  test ".convert_to from pt to us_pt" do
    assert_conversion Measured::Volume, "2 pt", "2.401899851 us_pt"
  end

  test ".convert_to from pt to oz" do
    assert_conversion Measured::Volume, "2 pt", "40 oz"
  end

  test ".convert_to from pt to us_oz" do
    assert_conversion Measured::Volume, "2 pt", "38.4303976162 us_oz"
  end

  test ".convert_to from us_pt to oz" do
    assert_conversion Measured::Volume, "2 us_pt", "33.3069673852 oz"
  end

  test ".convert_to from us_pt to us_oz" do
    assert_conversion Measured::Volume, "2 us_pt", "32 us_oz"
  end

  test ".convert_to from oz to us_oz" do
    assert_conversion Measured::Volume, "2 oz", "1.9215207864 us_oz"
  end
end
