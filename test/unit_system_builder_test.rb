require "test_helper"

class Measured::UnitSystemBuilderTest < ActiveSupport::TestCase
  test "#unit adds a new unit" do
    unit_system = Measured.build do
      unit :m
      unit :in, aliases: [:inch], value: "0.0254 m"
    end

    assert_equal 2, unit_system.unit_names.count
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
      Measured.build(case_sensitive: true) do
        unit :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :inch, aliases: [:thing], value: "123 m"
      end
    end

    assert_raises Measured::UnitError do
      Measured.build(case_sensitive: false) do
        unit :normal
        unit :bold, aliases: [:strong], value: "10 normal"
        unit :bolder, aliases: [:BOLD], value: "100 normal"
      end
    end
  end

  test ".build with case_sensitive: true produces a case-sensitive unit system" do
    unit_system = Measured.build(case_sensitive: true) do
      unit :normal
      unit :bold, value: "10 normal"
      unit :BOLD, value: "100 normal"
    end

    assert_equal Measured::UnitSystem, unit_system.superclass
    assert_equal 'BOLD', unit_system.unit_for!(:BOLD).name
  end

  test ".build produces case-insensitive unit system by default" do
    unit_system = Measured.build(case_sensitive: false) do
      unit :normal
      unit :bold, value: "10 normal"
      unit :bolder, value: "100 normal"
    end

    assert_equal Measured::CaseInsensitiveUnitSystem, unit_system.superclass
    assert_equal 'bold', unit_system.unit_for!(:bOlD).name
  end
end
