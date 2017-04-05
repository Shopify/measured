require "test_helper"

class Measured::WeightTest < ActiveSupport::TestCase
  setup do
    @weight = Measured::Weight.new(1, "g")
  end

  test ".unit_names_with_aliases should be the expected list of valid units" do
    assert_equal(
      %w(N T g gram grams kg kilogram kilograms lb lbs newton newtons ounce ounces oz pound pounds slug slugs t ton tonne tonnes tons),
      Measured::Weight.unit_names_with_aliases
    )
  end

  test ".unit_names should be the list of base unit names" do
    assert_equal %w(N T g kg lb oz slug t), Measured::Weight.unit_names
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

  test ".convert_to from g to T" do
    assert_exact_conversion Measured::Weight, "2000 g", "0.002 T"
  end

  test ".convert_to from g to N" do
    assert_conversion Measured::Weight, "2000 g", "0.20394324259558566 N"
  end

  test ".convert_to from g to t" do
    assert_conversion Measured::Weight, "2000 g", "0.002204623 t"
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

  test ".convert_to from kg to T" do
    assert_exact_conversion Measured::Weight, "2000 kg", "2 T"
  end

  test ".convert_to from kg to N" do
    assert_conversion Measured::Weight, "2000 kg", "203.94324259558567 N"
  end

  test ".convert_to from kg to t" do
    assert_conversion Measured::Weight, "2000 kg", "2.204623 t"
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

  test ".convert_to from lb to T" do
    assert_conversion Measured::Weight, "2000 lb", "0.9071847 T"
  end

  test ".convert_to from lb to N" do
    assert_conversion Measured::Weight, "2000 lb", "92.5070988 N"
  end

  test ".convert_to from lb to t" do
    assert_exact_conversion Measured::Weight, "2000 lb", "1 t"
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

  test ".convert_to from oz to T" do
    assert_conversion Measured::Weight, "2000 oz", "0.05669905 T"
  end

  test ".convert_to from oz to N" do
    assert_conversion Measured::Weight, "2000 oz", "5.78169367 N"
  end

  test ".convert_to from oz to t" do
    assert_exact_conversion Measured::Weight, "2000 oz", "0.0625 t"
  end

  test ".convert_to from T to g" do
    assert_exact_conversion Measured::Weight, "2000 T", "2000000000 g"
  end

  test ".convert_to from T to kg" do
    assert_exact_conversion Measured::Weight, "2000 T", "2000000 kg"
  end

  test ".convert_to from T to lb" do
    assert_conversion Measured::Weight, "2000 T", "4409245.243697552 lb"
  end

  test ".convert_to from T to oz" do
    assert_conversion Measured::Weight, "2000 T", "70547923.89916082 oz"
  end

  test ".convert_to from T to slug" do
    assert_conversion Measured::Weight, "2000 T", "137043.5311239221 slug"
  end

  test ".convert_to from T to T" do
    assert_exact_conversion Measured::Weight, "2000 T", "2000 T"
  end

  test ".convert_to from T to N" do
    assert_conversion Measured::Weight, "2000 T", "203943.24259558567 N"
  end

  test ".convert_to from T to t" do
    assert_conversion Measured::Weight, "2000 T", "2204.62262185 t"
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

  test ".convert_to from slug to T" do
    assert_conversion Measured::Weight, "2000 slug", "29.187806 T"
  end

  test ".convert_to from slug to N" do
    assert_conversion Measured::Weight, "2000 slug", "2976.3279 N"
  end

  test ".convert_to from slug to t" do
    assert_conversion Measured::Weight, "2000 slug", "32.17404869485539 t"
  end

  test ".convert_to from t to g" do
    assert_conversion Measured::Weight, "2000 t", "1814369480 g"
  end

  test ".convert_to from t to kg" do
    assert_conversion Measured::Weight, "2000 t", "1814369.48 kg"
  end

  test ".convert_to from t to lb" do
    assert_exact_conversion Measured::Weight, "2000 t", "4000000 lb"
  end

  test ".convert_to from t to oz" do
    assert_exact_conversion Measured::Weight, "2000 t", "64000000 oz"
  end

  test ".convert_to from t to slug" do
    assert_conversion Measured::Weight, "2000 t", "124323.80015133717 slug"
  end

  test ".convert_to from t to T" do
    assert_conversion Measured::Weight, "2000 t", "1814.36948 T"
  end

  test ".convert_to from t to N" do
    assert_conversion Measured::Weight, "2000 t", "185014.197509 N"
  end

  test ".convert_to from t to t" do
    assert_exact_conversion Measured::Weight, "2000 t", "2000 t"
  end

  test ".convert_to from N to g" do
    assert_conversion Measured::Weight, "2000 N", "19613300 g"
  end

  test ".convert_to from N to kg" do
    assert_conversion Measured::Weight, "2000 N", "19613.3 kg"
  end

  test ".convert_to from N to lb" do
    assert_conversion Measured::Weight, "2000 N", "43239.924869106595 lb"
  end

  test ".convert_to from N to oz" do
    assert_conversion Measured::Weight, "2000 N", "691838.7979057055 oz"
  end

  test ".convert_to from N to slug" do
    assert_conversion Measured::Weight, "2000 N", "1343.9379444964106 slug"
  end

  test ".convert_to from N to T" do
    assert_conversion Measured::Weight, "2000 N", "19.6133 T"
  end

  test ".convert_to from N to N" do
    assert_exact_conversion Measured::Weight, "2000 N", "2000 N"
  end

  test ".convert_to from N to t" do
    assert_conversion Measured::Weight, "2000 N", "21.619962434553297 t"
  end
end
