# frozen_string_literal: true
require "test_helper"

class Measured::FunctionalConversionTableBuilderTest < ActiveSupport::TestCase
  test "#initialize raises when cache is not null" do
    invalid_cache = { class: Measured::Cache::Json, args: ["volume.json"] }
    valid_cache = { class: Measured::Cache::Null, args: [] }

    assert_raises Measured::CacheError do
      Measured::FunctionalConversionTableBuilder.new([], cache: invalid_cache)
    end

    assert_nothing_raised do
      Measured::FunctionalConversionTableBuilder.new([], cache: valid_cache)
    end
  end

  test "#to_h returns self-conversion procs on the diagonal" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:base),
    ]).to_h

    identity = table["base"]["base"]
    assert identity.is_a?(Proc)
    assert_equal 42, identity.call(42)
    assert_equal BigDecimal("42.5"), identity.call(BigDecimal("42.5"))
    assert_instance_of BigDecimal, identity.call(BigDecimal("42.5"))
  end

  test "#to_h handles static units by wrapping them as procs" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:m),
      Measured::Unit.new(:cm, value: "0.01 m"),
    ]).to_h

    assert table["m"]["cm"].is_a?(Proc)
    assert_equal Rational(100, 1), table["m"]["cm"].call(1)
    assert_equal Rational(1, 100), table["cm"]["m"].call(1)
  end

  test "#to_h handles functional conversions" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:C),
      Measured::Unit.new(:K, value: [
        {
          forward: ->(k) { k - BigDecimal("273.15") },
          backward: ->(c) { c + BigDecimal("273.15") },
        }, "C"
      ]),
    ]).to_h

    assert_equal BigDecimal("0"), table["K"]["C"].call(BigDecimal("273.15"))
    assert_equal BigDecimal("273.15"), table["C"]["K"].call(BigDecimal("0"))
  end

  test "#to_h computes indirect functional paths" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:C),
      Measured::Unit.new(:K, value: [
        {
          forward: ->(k) { k - BigDecimal("273.15") },
          backward: ->(c) { c + BigDecimal("273.15") },
        }, "C"
      ]),
      Measured::Unit.new(:F, value: [
        {
          forward: ->(f) { (f - 32) * Rational(5, 9) },
          backward: ->(c) { c * Rational(9, 5) + 32 },
        }, "C"
      ]),
    ]).to_h

    # K to F (indirect: K -> C -> F)
    # 0 K = -273.15 C = -459.67 F
    result = table["K"]["F"].call(BigDecimal("0"))
    assert_equal BigDecimal("-459.67"), result

    # F to K (indirect: F -> C -> K)
    # 32 F = 0 C = 273.15 K
    result = table["F"]["K"].call(BigDecimal("32"))
    assert_equal BigDecimal("273.15"), result
  end

  test "#to_h handles mixed static and functional units with indirect paths" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:mm),
      Measured::Unit.new(:cm, value: [
        {
          forward: ->(cm) { Rational(10, 1) * cm },
          backward: ->(mm) { mm * Rational(1, 10) },
        }, "mm"
      ]),
      Measured::Unit.new(:dm, value: "10 cm"),
      Measured::Unit.new(:m, value: "10 dm"),
    ]).to_h

    [
      ["m", "m", Rational(1, 1)],
      ["m", "dm", Rational(10, 1)],
      ["m", "cm", Rational(100, 1)],
      ["m", "mm", Rational(1000, 1)],
      ["dm", "m", Rational(1, 10)],
      ["dm", "dm", Rational(1, 1)],
      ["dm", "cm", Rational(10, 1)],
      ["dm", "mm", Rational(100, 1)],
      ["cm", "m", Rational(1, 100)],
      ["cm", "dm", Rational(1, 10)],
      ["cm", "cm", Rational(1, 1)],
      ["cm", "mm", Rational(10, 1)],
      ["mm", "m", Rational(1, 1000)],
      ["mm", "dm", Rational(1, 100)],
      ["mm", "cm", Rational(1, 10)],
      ["mm", "mm", Rational(1, 1)],
    ].each do |(to, from, ratio)|
      assert conversion_table_entry = table[to][from], "Missing entry table[#{to}][#{from}]"
      assert conversion_table_entry.is_a?(Proc), "Expected Proc for table[#{to}][#{from}]"
      assert_equal ratio, conversion_table_entry.call(1), "Wrong conversion for table[#{to}][#{from}]"
    end
  end

  test "#update_cache raises CacheError" do
    builder = Measured::FunctionalConversionTableBuilder.new([Measured::Unit.new(:base)])
    assert_raises Measured::CacheError do
      builder.update_cache
    end
  end

  test "#cached? returns false" do
    builder = Measured::FunctionalConversionTableBuilder.new([Measured::Unit.new(:base)])
    refute_predicate builder, :cached?
  end

  test "#to_h raises on cycles" do
    unit1 = Measured::Unit.new(:a, value: [{ forward: ->(x) { x }, backward: ->(x) { x } }, "b"])
    unit2 = Measured::Unit.new(:b, value: [{ forward: ->(x) { x }, backward: ->(x) { x } }, "c"])
    unit3 = Measured::Unit.new(:c, value: [{ forward: ->(x) { x }, backward: ->(x) { x } }, "a"])

    assert_raises Measured::CycleDetected do
      Measured::FunctionalConversionTableBuilder.new([unit1, unit2, unit3]).to_h
    end
  end

  test "#to_h computes multi-hop paths across 4+ functional units" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:A),
      Measured::Unit.new(:B, value: [
        { forward: ->(b) { b * 2 }, backward: ->(a) { a / 2 } },
        "A"
      ]),
      Measured::Unit.new(:C, value: [
        { forward: ->(c) { c * 3 }, backward: ->(b) { b / 3 } },
        "B"
      ]),
      Measured::Unit.new(:D, value: [
        { forward: ->(d) { d * 5 }, backward: ->(c) { c / 5 } },
        "C"
      ]),
    ]).to_h

    # D -> A requires 3 hops: D -> C -> B -> A
    # D=1 -> C=5 -> B=15 -> A=30
    assert_equal Rational(30), table["D"]["A"].call(1)
    # A -> D is the reverse: A=30 -> B=15 -> C=5 -> D=1
    assert_equal Rational(1), table["A"]["D"].call(30)

    %w(A B C D).each do |from|
      %w(A B C D).each do |to|
        assert table[from][to].is_a?(Proc), "Missing table[#{from}][#{to}]"
        result = table[to][from].call(table[from][to].call(Rational(7)))
        assert_equal Rational(7), result, "Round-trip failed for #{from} -> #{to} -> #{from}"
      end
    end
  end

  test "#to_h wraps static Rational amounts as procs preserving type" do
    table = Measured::FunctionalConversionTableBuilder.new([
      Measured::Unit.new(:m),
      Measured::Unit.new(:cm, value: "0.01 m"),
    ]).to_h

    assert_equal Rational(100), table["m"]["cm"].call(Rational(1))
    assert_instance_of Rational, table["m"]["cm"].call(Rational(1))
    assert_equal Rational(50), table["m"]["cm"].call(BigDecimal("0.5"))
  end

  test "#initialize with no cache argument defaults to Null and succeeds" do
    assert_nothing_raised do
      Measured::FunctionalConversionTableBuilder.new([Measured::Unit.new(:base)])
    end
  end
end
