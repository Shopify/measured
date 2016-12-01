require "test_helper"

class Measured::ConversionBuilderTest < ActiveSupport::TestCase
  test "#base sets the base unit" do
    conversion = Measured.build { base :m, aliases: [:metre] }.conversion
    assert_equal ["m", "metre"], conversion.base_unit.names
  end

  test "#base doesn't allow a second base to be added" do
    assert_raises Measured::UnitError do
      Measured.build do
        base :m, aliases: [:metre]
        base :in
      end
    end
  end

  test "raises UnitError when no base unit set" do
    assert_raises Measured::UnitError do
      Measured.build do
        unit :m, aliases: [:metre], value: "100 cm"
      end
    end
  end

  test "#unit adds a new unit" do
    measurable = Measured.build do
      base :m
      unit :in, aliases: [:inch], value: "0.0254 m"
    end

    assert_equal 2, measurable.units.count
  end

  test "#unit cannot add duplicate unit names" do
    assert_raises Measured::UnitError do
      Measured.build do
        base :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :in, aliases: [:thing], value: "123 m"
      end
    end

    assert_raises Measured::UnitError do
      Measured.build(case_sensitive: true) do
        base :m
        unit :in, aliases: [:inch], value: "0.0254 m"
        unit :inch, aliases: [:thing], value: "123 m"
      end
    end

    assert_raises Measured::UnitError do
      Measured.build(case_sensitive: false) do
        base :normal
        unit :bold, aliases: [:strong], value: "10 normal"
        unit :bolder, aliases: [:BOLD], value: "100 normal"
      end
    end
  end

  test "#case_sensitive true produces a case-sensitive conversion" do
    measurable = Measured.build(case_sensitive: true) do
      base :normal
      unit :bold, value: "10 normal"
      unit :BOLD, value: "100 normal"
    end

    assert_equal 2, measurable.new(200, :normal).convert_to(:BOLD).value
  end

  test "case-insensitive conversion is produced by defaul" do
    measurable = Measured.build(case_sensitive: false) do
      base :normal
      unit :bold, value: "10 normal"
      unit :bolder, value: "100 normal"
    end

    assert_equal 20, measurable.new(200, :normal).convert_to(:bOlD).value
  end
end
