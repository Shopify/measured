require "test_helper"

class Measured::ConversionTableBuilderTest < ActiveSupport::TestCase
  test "#initialize creates a new object with the units" do
    units = [Measured::Unit.new(:test)]

    assert_equal units, Measured::ConversionTableBuilder.new(units).units
  end

  test "#to_h should return a hash for the simple case" do
    conversion_table = Measured::ConversionTableBuilder.new([Measured::Unit.new(:test)]).to_h

    expected = {
      "test" => {"test" => Rational(1, 1)}
    }

    assert_equal expected, conversion_table
    assert_instance_of Rational, conversion_table.values.first.values.first
  end

  test "#to_h returns expected nested hashes with BigDecimal conversion factors in a tiny data set" do
    conversion_table = Measured::ConversionTableBuilder.new([
      Measured::Unit.new(:m),
      Measured::Unit.new(:cm, value: "0.01 m"),
    ]).to_h

    expected = {
      "m" => {
        "m" => Rational(1, 1),
        "cm" => Rational(100, 1),
      },
      "cm" => {
        "m" => Rational(1, 100),
        "cm" => Rational(1, 1),
      }
    }

    assert_equal expected, conversion_table

    conversion_table.values.map(&:values).flatten.each do |value|
      assert_instance_of Rational, value
    end
  end

  test "#to_h returns expected nested hashes factors" do
    conversion_table = Measured::ConversionTableBuilder.new([
      Measured::Unit.new(:m),
      Measured::Unit.new(:cm, value: "0.01 m"),
      Measured::Unit.new(:mm, value: "0.001 m"),
    ]).to_h

    expected = {
      "m" => {
        "m" => Rational(1, 1),
        "cm" => Rational(100, 1),
        "mm" => Rational(1000, 1),
      },
      "cm" => {
        "m" => Rational(1, 100),
        "cm" => Rational(1, 1),
        "mm" => Rational(10, 1),
      },
      "mm" => {
        "m" => Rational(1, 1000),
        "cm" => Rational(1, 10),
        "mm" => Rational(1, 1),
      }
    }

    assert_equal expected, conversion_table

    conversion_table.values.map(&:values).flatten.each do |value|
      assert_instance_of Rational, value
    end
  end

  test "#to_h returns expected nested hashes in an indrect path" do
    conversion_table = Measured::ConversionTableBuilder.new([
      Measured::Unit.new(:mm),
      Measured::Unit.new(:cm, value: "10 mm"),
      Measured::Unit.new(:dm, value: "10 cm"),
      Measured::Unit.new(:m, value: "10 dm"),
    ]).to_h

    expected = {
      "m" => {
        "m" => Rational(1, 1),
        "dm" => Rational(10, 1),
        "cm" => Rational(100, 1),
        "mm" => Rational(1000, 1),
      },
      "cm" => {
        "m" => Rational(1, 100),
        "dm" => Rational(1, 10),
        "cm" => Rational(1, 1),
        "mm" => Rational(10, 1),
      },
      "dm" => {
        "m" => Rational(1, 10),
        "cm" => Rational(10, 1),
        "dm" => Rational(1, 1),
        "mm" => Rational(100, 1),
      },
      "mm" => {
        "m" => Rational(1, 1000),
        "dm" => Rational(1, 100),
        "cm" => Rational(1, 10),
        "mm" => Rational(1, 1),
      }
    }

    assert_equal expected, conversion_table

    conversion_table.values.map(&:values).flatten.each do |value|
      assert_instance_of Rational, value
    end
  end

  test "#cached? returns true if there's a cache" do
    builder = Measured::ConversionTableBuilder.new([Measured::Unit.new(:test)], cache: { class: AlwaysTrueCache })
    assert_predicate builder, :cached?
  end

  test "#cached? returns false if there is not a cache" do
    builder = Measured::ConversionTableBuilder.new([Measured::Unit.new(:test)])
    refute_predicate builder, :cached?
  end

  test "#write_cache pushes the generated table into the cache and writes it" do
    builder = Measured::ConversionTableBuilder.new([Measured::Unit.new(:test)], cache: { class: AlwaysTrueCache })
    AlwaysTrueCache.any_instance.expects(:exist?).returns(false)
    table = builder.to_h
    AlwaysTrueCache.any_instance.expects(:write).with(table).returns(123)
    assert_equal 123, builder.update_cache
  end
end
