require "test_helper"

class Measured::UnitSystemBuilderTest < ActiveSupport::TestCase
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

  test "#si_unit adds 20 new units" do
    measurable = Measured.build do
      unit :ft
      si_unit :in, value: "12 ft", aliases: [:ins]
    end

    assert_equal 22, measurable.unit_names.count
  end

  test "#si_unit creates units with proper prefixes" do
    measurable = Measured.build do
      unit :in
      si_unit :ft, value: "12 in", aliases: [:fts]
    end

    prefixes = Measured::UnitSystemBuilder.prefixes.map {|short, long, exp| "#{short}ft"}.push('in')
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

    assert_equal 'yBOLD', measurable.unit_system.unit_for!(:yBOLD).name
    assert_equal 'YBOLD', measurable.unit_system.unit_for!(:YBOLD).name
    assert_equal 'BOLD', measurable.unit_system.unit_for!(:BOLD).name
  end
end
