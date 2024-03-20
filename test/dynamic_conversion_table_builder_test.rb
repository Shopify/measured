# frozen_string_literal: true
require "test_helper"

class Measured::DynamicConversionTableBuilderTest < ActiveSupport::TestCase
  test "#initialize raises when cache is not null" do
    invalid_cache_arguments = { class: Measured::Cache::Json, args: ["volume.json"] }
    valid_cache_arguments = { class: Measured::Cache::Null, args: [] }

    assert_raises Measured::CacheError do
      Measured::DynamicConversionTableBuilder.new([], cache: invalid_cache_arguments)
    end

    assert_nothing_raised do
      Measured::DynamicConversionTableBuilder.new([], cache: valid_cache_arguments)
    end
  end

  test "#to_h returns expected nested hashes in an indrect path" do
    conversion_table = Measured::DynamicConversionTableBuilder.new([
      Measured::Unit.new(:mm),
      Measured::Unit.new(:cm, value: [
        {
          conversion: ->(cm) { Rational(10,1) * cm },
          reverse_conversion: ->(mm) { mm * Rational(1,10) },
          description: '10 mm',
        },
        "mm"
      ]),
      Measured::Unit.new(:dm, value: "10 cm"),
      Measured::Unit.new(:m, value: "10 dm"),
    ]).to_h

    [
      ["m", "m", Rational(1,1)],
      ["m", "dm", Rational(10,1)],
      ["m", "cm", Rational(100,1)],
      ["m", "mm", Rational(1000,1)],
      ["dm", "m", Rational(1,10)],
      ["dm", "dm", Rational(1,1)],
      ["dm", "cm", Rational(10,1)],
      ["dm", "mm", Rational(100,1)],
      ["cm", "m", Rational(1,100)],
      ["cm", "dm", Rational(1,10)],
      ["cm", "cm", Rational(1,1)],
      ["cm", "mm", Rational(10,1)],
      ["mm", "m", Rational(1,1000)],
      ["mm", "dm", Rational(1,100)],
      ["mm", "cm", Rational(1,10)],
      ["mm", "mm", Rational(1,1)]
    ].each do |(to, from, ratio)|
      assert conversion_table[to][from].is_a?(Proc)
      assert_equal ratio, conversion_table[to][from].call(1)
    end
  end
end