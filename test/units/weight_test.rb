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

end
