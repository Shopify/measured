# frozen_string_literal: true
require "test_helper"

class Measured::UnitSystemBuilderTest < Minitest::Test
  test "#unit adds a new unit" do
    measurable = Measured.build do
      unit :m
      unit :in, aliases: [:inch], value: "0.0254 m"
    end

    assert_equal 2, measurable.unit_names.count
  end

  test "#unit cannot add duplicate unit names" do
    assert_raises Measured::UnitError do
      Measured.build do
        unit :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :in, aliases: [:thing], value: "123 m"
      end
    end

    assert_raises Measured::UnitError do
      Measured.build do
        unit :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :inch, aliases: [:thing], value: "123 m"
      end
    end
  end

  test "#unit is case sensitive" do
    measurable = Measured.build do
      unit :normal
      unit :bold, value: "10 normal"
      unit :BOLD, value: "100 normal"
    end

    assert_equal 'BOLD', measurable.unit_system.unit_for!(:BOLD).name
  end

  test "#si_unit adds 21 new units" do
    measurable = Measured.build do
      unit :ft
      si_unit :in, value: "12 ft", aliases: [:ins]
    end

    assert_equal 22, measurable.unit_names.count
  end

  test "#si_unit creates units with si prefixes" do
    measurable = Measured.build do
      unit :in
      si_unit :ft, value: "12 in", aliases: [:fts]
    end

    prefixes = Measured::UnitSystemBuilder::SI_PREFIXES.map { |short, _, _| "#{short}ft" }
    prefixes += %w(in ft)
    assert_equal prefixes.sort, measurable.unit_names
  end

  test "#si_unit cannot add duplicate unit names" do
    assert_raises Measured::UnitError do
      Measured.build do
        unit :m
        si_unit :in, aliases: [:inch], value: "0.0254 m"
        si_unit :in, aliases: [:thing], value: "123 m"
      end
    end

    assert_raises Measured::UnitError do
      Measured.build do
        unit :m
        si_unit :in, aliases: [:inch], value: "0.0254 m"
        si_unit :inch, aliases: [:thing], value: "123 m"
      end
    end
  end

  test "#si_unit is case sensitive" do
    measurable = Measured.build do
      unit :normal
      si_unit :bold, value: "10 normal"
      si_unit :BOLD, value: "100 normal"
    end

    assert_equal "yBOLD", measurable.unit_system.unit_for!(:yBOLD).name
    assert_equal "YBOLD", measurable.unit_system.unit_for!(:YBOLD).name
    assert_equal "BOLD", measurable.unit_system.unit_for!(:BOLD).name
  end

  test "#si_unit generates working units when given base unit" do
    measurable = Measured.build do
      si_unit :g, aliases: [:gram, :grams]
      unit :bigg, value: "1000 g"
    end

    assert_equal 1000, measurable.unit_system.unit_for!(:bigg).conversion_amount
    assert_equal "g", measurable.unit_system.unit_for!(:bigg).conversion_unit
    assert_equal 1000, measurable.unit_system.unit_for!(:kg).conversion_amount
    assert_equal "g", measurable.unit_system.unit_for!(:kg).conversion_unit
  end

  test "#si_unit generates working units when given non base unit" do
    measurable = Measured.build do
      unit :lb
      si_unit :long_ton, value: "2240 lb", aliases: ["long ton", "long tons"]
    end

    assert_equal (2240), measurable.unit_system.unit_for!(:long_ton).conversion_amount
    assert_equal "lb", measurable.unit_system.unit_for!(:long_ton).conversion_unit
  end

  test "#cache sets no cache by default" do
    measurable = Measured.build do
      unit :m
      unit :km, value: "1000 m"
    end

    refute_predicate measurable.unit_system, :cached?
  end

  test "#cache sets the class and args" do
    measurable = Measured.build do
      unit :m
      unit :km, value: "1000 m"

      cache AlwaysTrueCache
    end

    assert_predicate measurable.unit_system, :cached?
  end
end
