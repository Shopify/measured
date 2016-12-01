class Measured::ConversionBuilder
  def initialize
    @base_unit = nil
    @units = []
    @case_sensitive = false
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

  def case_sensitive(value)
    @case_sensitive = !!value
    nil
  end

  def conversion
    raise Measured::UnitError, "A base unit has not been set." unless @base_unit
    Measured::Conversion.new(@base_unit, @units, case_sensitive: @case_sensitive)
  end

  private

  def build_unit(name, aliases: [], value: nil)
    unit = Measured::Unit.new(name, aliases: aliases, value: value)
    check_for_duplicate_unit_names!(unit)
    unit
  end

  def check_for_duplicate_unit_names!(unit)
    names = @units.flat_map(&:names)
    names += @base_unit.names if @base_unit
    
    if names.any? { |name| unit.names_include?(name, case_sensitive: @case_sensitive) }
      raise Measured::UnitError, "Unit #{unit.name} has already been added."
    end
  end
end
