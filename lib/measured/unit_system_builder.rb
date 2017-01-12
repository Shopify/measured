class Measured::ConversionBuilder
  def initialize(case_sensitive: false)
    @units = []
    @case_sensitive = case_sensitive
  end

  def unit(unit_name, aliases: [], value: nil)
    @units << build_unit(unit_name, aliases: aliases, value: value)
    nil
  end

  def conversion
    conversion_class.new(@units)
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

  def conversion_class
    @case_sensitive ? Measured::Conversion : Measured::CaseInsensitiveConversion
  end

  def check_for_duplicate_unit_names!(unit)
    names = @units.flat_map(&:names)
    if names.any? { |name| unit.names.include?(name) }
      raise Measured::UnitError, "Unit #{unit.name} has already been added."
    end
  end
end
