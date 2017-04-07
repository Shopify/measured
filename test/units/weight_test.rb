require "test_helper"

class Measured::WeightTest < ActiveSupport::TestCase
  setup do
    @weight = Measured::Weight.new(1, "g")
  end

  test ".unit_names_with_aliases should be the expected list of valid units" do
    assert_equal(
      %w(N g gram grams kg kilogram kilograms lb lbs long_ton long_tons newton newtons ounce ounces oz pound pounds short_ton short_tons slug slugs),
      Measured::Weight.unit_names_with_aliases
    )
  end

  test ".unit_names should be the list of base unit names" do
    assert_equal %w(N g kg lb long_ton oz short_ton slug), Measured::Weight.unit_names
  end

  test "Measured::Weight() delegates automatically to .new" do
    assert_equal Measured::Weight.new(1, :lb), Measured::Weight(1, :lb)
    assert_equal Measured::Weight.new(2000, :g), Measured::Weight(2, :kg)
  end

  test ".name" do
    assert_equal "weight", Measured::Weight.name
  end

  test ".convert_to from g to g" do
    assert_exact_conversion Measured::Weight, "2000 g", "2000 g"
  end

  test ".convert_to from g to kg" do
    assert_exact_conversion Measured::Weight, "2000 g", "2 kg"
  end

  test ".convert_to from g to lb" do
    assert_conversion Measured::Weight, "2000 g", "4.40924524 lb"
  end

  test ".convert_to from g to oz" do
    assert_conversion Measured::Weight, "2000 g", "70.54792384 oz"
  end

  test ".convert_to from g to slug" do
    assert_conversion Measured::Weight, "2000 g", "0.1370435 slug"
  end

  test ".convert_to from g to N" do
    assert_conversion Measured::Weight, "2000 g", "19.6133 N"
  end

  test ".convert_to from g to short_ton" do
    assert_conversion Measured::Weight, "2000 g", "0.002204623 short_ton"
  end

  test ".convert_to from g to long_ton" do
    assert_conversion Measured::Weight, "2000 g", "0.001968413055222 long_ton"
  end

  test ".convert_to from kg to g" do
    assert_exact_conversion Measured::Weight, "2000 kg", "2000000 g"
  end

  test ".convert_to from kg to kg" do
    assert_exact_conversion Measured::Weight, "2000 kg", "2000 kg"
  end

  test ".convert_to from kg to lb" do
    assert_conversion Measured::Weight, "2000 kg", "4409.245243 lb"
  end

  test ".convert_to from kg to oz" do
    assert_conversion Measured::Weight, "2000 kg", "70547.92390 oz"
  end

  test ".convert_to from kg to slug" do
    assert_conversion Measured::Weight, "2000 kg", "137.0435311239221 slug"
  end

  test ".convert_to from kg to N" do
    assert_conversion Measured::Weight, "2000 kg", "19613.3 N"
  end

  test ".convert_to from kg to short_ton" do
    assert_conversion Measured::Weight, "2000 kg", "2.204622621848 short_ton"
  end

  test ".convert_to from kg to long_ton" do
    assert_conversion Measured::Weight, "2000 kg", "1.9684130552220003 long_ton"
  end

  test ".convert_to from lb to g" do
    assert_exact_conversion Measured::Weight, "2000 lb", "907184.74 g"
  end

  test ".convert_to from lb to kg" do
    assert_exact_conversion Measured::Weight, "2000 lb", "907.18474 kg"
  end

  test ".convert_to from lb to lb" do
    assert_exact_conversion Measured::Weight, "2000 lb", "2000 lb"
  end

  test ".convert_to from lb to oz" do
    assert_exact_conversion Measured::Weight, "2000 lb", "32000 oz"
  end

  test ".convert_to from lb to slug" do
    assert_conversion Measured::Weight, "2000 lb", "62.16190007566859 slug"
  end

  test ".convert_to from lb to N" do
    assert_conversion Measured::Weight, "2000 lb", "8896.443230521 N"
  end

  test ".convert_to from lb to short_ton" do
    assert_exact_conversion Measured::Weight, "2000 lb", "1 short_ton"
  end

  test ".convert_to from lb to long_ton" do
    assert_conversion Measured::Weight, "2000 lb", "0.892857142857088 long_ton"
  end

  test ".convert_to from oz to g" do
    assert_conversion Measured::Weight, "2000 oz", "56699.04625 g"
  end

  test ".convert_to from oz to kg" do
    assert_conversion Measured::Weight, "2000 oz", "56.69904625 kg"
  end

  test ".convert_to from oz to lb" do
    assert_exact_conversion Measured::Weight, "2000 oz", "125 lb"
  end

  test ".convert_to from oz to oz" do
    assert_exact_conversion Measured::Weight, "2000 oz", "2000 oz"
  end

  test ".convert_to from oz to slug" do
    assert_conversion Measured::Weight, "2000 oz", "3.885119 slug"
  end

  test ".convert_to from oz to N" do
    assert_conversion Measured::Weight, "2000 oz", "556.0277019075625 N"
  end

  test ".convert_to from oz to short_ton" do
    assert_conversion Measured::Weight, "2000 oz", "0.06249999999997801 short_ton"
  end

  test ".convert_to from oz to long_ton" do
    assert_conversion Measured::Weight, "2000 oz", "0.055803571428568 long_ton"
  end

  test ".convert_to from slug to g" do
    assert_conversion Measured::Weight, "2000 slug", "29187806 g"
  end

  test ".convert_to from slug to kg" do
    assert_conversion Measured::Weight, "2000 slug", "29187.805999999997 kg"
  end

  test ".convert_to from slug to lb" do
    assert_conversion Measured::Weight, "2000 slug", "64348.09738973343 lb"
  end

  test ".convert_to from slug to oz" do
    assert_conversion Measured::Weight, "2000 slug", "1029569.5582357347 oz"
  end

  test ".convert_to from slug to slug" do
    assert_exact_conversion Measured::Weight, "2000 slug", "2000 slug"
  end

  test ".convert_to from slug to N" do
    assert_conversion Measured::Weight, "2000 slug", "286234.59770989994 N"
  end

  test ".convert_to from slug to short_ton" do
    assert_conversion Measured::Weight, "2000 slug", "32.17404869485539 short_ton"
  end

  test ".convert_to from slug to long_ton" do
    assert_conversion Measured::Weight, "2000 slug", "28.726829191843514 long_ton"
  end

  test ".convert_to from short_ton to g" do
    assert_conversion Measured::Weight, "2000 short_ton", "1814369480 g"
  end

  test ".convert_to from short_ton to kg" do
    assert_conversion Measured::Weight, "2000 short_ton", "1814369.48 kg"
  end

  test ".convert_to from short_ton to lb" do
    assert_exact_conversion Measured::Weight, "2000 short_ton", "4000000 lb"
  end

  test ".convert_to from short_ton to oz" do
    assert_exact_conversion Measured::Weight, "2000 short_ton", "64000000 oz"
  end

  test ".convert_to from short_ton to slug" do
    assert_conversion Measured::Weight, "2000 short_ton", "124323.80015133717 slug"
  end

  test ".convert_to from short_ton to N" do
    assert_conversion Measured::Weight, "2000 short_ton", "17792886.461041998 N"
  end

  test ".convert_to from short_ton to short_ton" do
    assert_exact_conversion Measured::Weight, "2000 short_ton", "2000 short_ton"
  end

  test ".convert_to from short_ton to long_ton" do
    assert_conversion Measured::Weight, "2000 short_ton", "1785.714285714176 long_ton"
  end

  test ".convert_to from long_ton to g" do
    assert_conversion Measured::Weight, "2000 long_ton", "2032093817.6 g"
  end

  test ".convert_to from long_ton to kg" do
    assert_conversion Measured::Weight, "2000 long_ton", "2032093.8176 kg"
  end

  test ".convert_to from long_ton to lb" do
    assert_exact_conversion Measured::Weight, "2000 long_ton", "4480000 lb"
  end

  test ".convert_to from long_ton to oz" do
    assert_exact_conversion Measured::Weight, "2000 long_ton", "71680000 oz"
  end

  test ".convert_to from long_ton to slug" do
    assert_conversion Measured::Weight, "2000 long_ton", "139242.65616949764 slug"
  end

  test ".convert_to from long_ton to N" do
    assert_conversion Measured::Weight, "2000 long_ton", "19928032.836367033 N"
  end

  test ".convert_to from long_ton to short_ton" do
    assert_exact_conversion Measured::Weight, "2000 long_ton", "2240 short_ton"
  end

  test ".convert_to from long_ton to long_ton" do
    assert_conversion Measured::Weight, "2000 long_ton", "2000 long_ton"
  end

  test ".convert_to from N to g" do
    assert_conversion Measured::Weight, "2000 N", "203943.24259558567 g"
  end

  test ".convert_to from N to kg" do
    assert_conversion Measured::Weight, "2000 N", "203.9432425955857 kg"
  end

  test ".convert_to from N to lb" do
    assert_conversion Measured::Weight, "2000 N", "449.6178861994211 lb"
  end

  test ".convert_to from N to oz" do
    assert_conversion Measured::Weight, "2000 N", "7193.886179190737 oz"
  end

  test ".convert_to from N to slug" do
    assert_conversion Measured::Weight, "2000 N", "13.974551057080868 slug"
  end

  test ".convert_to from N to N" do
    assert_exact_conversion Measured::Weight, "2000 N", "2000 N"
  end

  test ".convert_to from N to short_ton" do
    assert_conversion Measured::Weight, "2000 N", "0.2248089430996314 short_ton"
  end

  test ".convert_to from N to long_ton" do
    assert_conversion Measured::Weight, "2000 N", "0.20072227062472917 long_ton"
  end
end
