class Measured::ConversionBuilder
  def initialize(case_sensitive: false)
    @base_unit = nil
    @units = []
    @case_sensitive = case_sensitive
  end

  def base(unit_name, aliases: [])
    raise Measured::UnitError, "Setting #{unit_name} as base unit, but already defined as #{@base_unit}." if @base_unit
    @base_unit = build_unit(unit_name, aliases: aliases)
    nil
  end

  def unit(unit_name, aliases: [], value:)
    @units << build_unit(unit_name, aliases: aliases, value: value)
    nil
  end

  def conversion
    raise Measured::UnitError, "A base unit has not been set." unless @base_unit
    Measured::Conversion.new(@base_unit, @units)
  end

  private

  def build_unit(name, aliases: [], value: nil)
    unit = unit_class.new(name, aliases: aliases, value: value)
    check_for_duplicate_unit_names!(unit)
    unit
  end

  def unit_class
    @case_sensitive ? Measured::Unit : Measured::CaseInsensitiveUnit
  end

  def check_for_duplicate_unit_names!(unit)
    names = @units.flat_map(&:names)
    names += @base_unit.names if @base_unit

    if names.any? { |name| unit.names_include?(name) }
      raise Measured::UnitError, "Unit #{unit.name} has already been added."
    end
  end
end
