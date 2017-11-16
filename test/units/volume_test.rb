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
    assert_conversion Measured::Volume, "2000 ml", "0.07067137809 ft3"
  end

  test ".convert_to from ml to in3" do
    assert_conversion Measured::Volume, "2000 ml", "122.1200788173 in3"
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
    assert_conversion Measured::Volume, "2000 ml", "4.2267548297 us_pt"
  end

  test ".convert_to from ml to oz" do
    assert_conversion Measured::Volume, "2000 ml", "70.39016 oz"
  end

  test ".convert_to from ml to us_oz" do
    assert_conversion Measured::Volume, "2000 ml", "67.6280772756 us_oz"
  end

  test ".convert_to from m3 to ft3" do
    assert_conversion Measured::Volume, "2 m3", "70.6713780919 ft3"
  end

  test ".convert_to from m3 to in3" do
    assert_conversion Measured::Volume, "2 m3", "122120.078817276 in3"
  end

  test ".convert_to from m3 to gal" do
    assert_conversion Measured::Volume, "2 m3", "439.9384965982 gal"
  end

  test ".convert_to from m3 to us_gal" do
    assert_conversion Measured::Volume, "2 m3", "528.344353716 us_gal"
  end

  test ".convert_to from m3 to qt" do
    assert_conversion Measured::Volume, "2 m3", "1759.7539863927 qt"
  end

  test ".convert_to from m3 to us_qt" do
    assert_conversion Measured::Volume, "2 m3", "2113.3774148639 us_qt"
  end

  test ".convert_to from m3 to pt" do
    assert_conversion Measured::Volume, "2 m3", "3519.5079727854 pt"
  end

  test ".convert_to from m3 to us_pt" do
    assert_conversion Measured::Volume, "2 m3", "4226.7548297278 us_pt"
  end

  test ".convert_to from m3 to oz" do
    assert_conversion Measured::Volume, "2 m3", "70390.1594557081 oz"
  end

  test ".convert_to from m3 to us_oz" do
    assert_conversion Measured::Volume, "2 m3", "67628.0772756452 us_oz"
  end

  test ".convert_to from ft3 to in3" do
    assert_conversion Measured::Volume, "2 ft3", "3455.9982305289 in3"
  end

  test ".convert_to from ft3 to gal" do
    assert_conversion Measured::Volume, "2 ft3", "12.4502594537 gal"
  end

  test ".convert_to from ft3 to us_gal" do
    assert_conversion Measured::Volume, "2 ft3", "14.9521452102 us_gal"
  end

  test ".convert_to from ft3 to qt" do
    assert_conversion Measured::Volume, "2 ft3", "49.8010378149 qt"
  end

  test ".convert_to from ft3 to us_qt" do
    assert_conversion Measured::Volume, "2 ft3", "59.8085808406 us_qt"
  end

  test ".convert_to from ft3 to pt" do
    assert_conversion Measured::Volume, "2 ft3", "99.6020756298 pt"
  end

  test ".convert_to from ft3 to us_pt" do
    assert_conversion Measured::Volume, "2 ft3", "119.6171616813 us_pt"
  end

  test ".convert_to from ft3 to oz" do
    assert_conversion Measured::Volume, "2 ft3", "1992.0415125965 oz"
  end

  test ".convert_to from ft3 to us_oz" do
    assert_conversion Measured::Volume, "2 ft3", "1913.8745869008 us_oz"
  end

  test ".convert_to from in3 to gal" do
    assert_conversion Measured::Volume, "2 in3", "0.007205014947 gal"
  end

  test ".convert_to from in3 to us_gal" do
    assert_conversion Measured::Volume, "2 in3", "0.008652866242 us_gal"
  end

  test ".convert_to from in3 to qt" do
    assert_conversion Measured::Volume, "2 in3", "0.02882005979 qt"
  end

  test ".convert_to from in3 to us_qt" do
    assert_conversion Measured::Volume, "2 in3", "0.03461146497 us_qt"
  end

  test ".convert_to from in3 to pt" do
    assert_conversion Measured::Volume, "2 in3", "0.05764011958 pt"
  end

  test ".convert_to from in3 to us_pt" do
    assert_conversion Measured::Volume, "2 in3", "0.06922292993 us_pt"
  end

  test ".convert_to from in3 to oz" do
    assert_conversion Measured::Volume, "2 in3", "1.1528023915 oz"
  end

  test ".convert_to from in3 to us_oz" do
    assert_conversion Measured::Volume, "2 in3", "1.1075668789 us_oz"
  end

  test ".convert_to from gal to us_gal" do
    assert_conversion Measured::Volume, "2 gal", "2.401900983 us_gal"
  end

  test ".convert_to from gal to qt" do
    assert_conversion Measured::Volume, "2 gal", "8 qt"
  end

  test ".convert_to from gal to us_qt" do
    assert_conversion Measured::Volume, "2 gal", "9.6076039319 us_qt"
  end

  test ".convert_to from gal to pt" do
    assert_conversion Measured::Volume, "2 gal", "16 pt"
  end

  test ".convert_to from gal to us_pt" do
    assert_conversion Measured::Volume, "2 gal", "19.2152078639 us_pt"
  end

  test ".convert_to from gal to oz" do
    assert_conversion Measured::Volume, "2 gal", "320 oz"
  end

  test ".convert_to from gal to us_oz" do
    assert_conversion Measured::Volume, "2 gal", "307.443325822 us_oz"
  end
  
  test ".convert_to from us_gal to qt" do
    assert_conversion Measured::Volume, "2 us_gal", "6.6613903376 qt"
  end

  test ".convert_to from us_gal to us_qt" do
    assert_conversion Measured::Volume, "2 us_gal", "8 us_qt"
  end

  test ".convert_to from us_gal to pt" do
    assert_conversion Measured::Volume, "2 us_gal", "13.3227806753 pt"
  end

  test ".convert_to from us_gal to us_pt" do
    assert_conversion Measured::Volume, "2 us_gal", "16 us_pt"
  end

  test ".convert_to from us_gal to oz" do
    assert_conversion Measured::Volume, "2 us_gal", "266.4556135052 oz"
  end

  test ".convert_to from us_gal to us_oz" do
    assert_conversion Measured::Volume, "2 us_gal", "256 us_oz"
  end

  test ".convert_to from qt to us_qt" do
    assert_conversion Measured::Volume, "2 qt", "2.401900983 us_qt"
  end

  test ".convert_to from qt to pt" do
    assert_conversion Measured::Volume, "2 qt", "4 pt"
  end

  test ".convert_to from qt to us_pt" do
    assert_conversion Measured::Volume, "2 qt", "4.803801966 us_pt"
  end

  test ".convert_to from qt to oz" do
    assert_conversion Measured::Volume, "2 qt", "80 oz"
  end

  test ".convert_to from qt to us_oz" do
    assert_conversion Measured::Volume, "2 qt", "76.8608314555 us_oz"
  end

  test ".convert_to from us_qt to pt" do
    assert_conversion Measured::Volume, "2 us_qt", "3.3306951688 pt"
  end

  test ".convert_to from us_qt to us_pt" do
    assert_conversion Measured::Volume, "2 us_qt", "4 us_pt"
  end

  test ".convert_to from us_qt to oz" do
    assert_conversion Measured::Volume, "2 us_qt", "66.6139033763 oz"
  end

  test ".convert_to from us_qt to us_oz" do
    assert_conversion Measured::Volume, "2 us_qt", "64 us_oz"
  end

  test ".convert_to from pt to us_pt" do
    assert_conversion Measured::Volume, "2 pt", "2.401900983 us_pt"
  end

  test ".convert_to from pt to oz" do
    assert_conversion Measured::Volume, "2 pt", "40 oz"
  end

  test ".convert_to from pt to us_oz" do
    assert_conversion Measured::Volume, "2 pt", "38.4304157278 us_oz"
  end

  test ".convert_to from us_pt to oz" do
    assert_conversion Measured::Volume, "2 us_pt", "33.3069516882 oz"
  end

  test ".convert_to from us_pt to us_oz" do
    assert_conversion Measured::Volume, "2 us_pt", "32 us_oz"
  end

  test ".convert_to from oz to us_oz" do
    assert_conversion Measured::Volume, "2 oz", "1.9215207864 us_oz"
  end
end