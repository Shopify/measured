class Measured::Conversion
  ARBITRARY_CONVERSION_PRECISION = 20

  def initialize(base_unit, units, case_sensitive: false)
    @case_sensitive = case_sensitive
    @base_unit = base_unit
    @units = units.dup
    @units << @base_unit
  end

  attr_reader :base_unit, :units

  def unit_names_with_aliases
    @unit_names_with_aliases ||= @units.flat_map(&:names).sort
  end

  def unit_names
    @unit_names ||= @units.map(&:name).sort
  end

  def unit_or_alias?(name)
    @units.any? { |unit| unit.names_include?(name, case_sensitive: @case_sensitive) }
  end

  def unit?(name)
    @units.any? { |unit| unit.name_eql?(name, case_sensitive: @case_sensitive) }
  end

  def to_unit_name(name)
    unit_for!(name).name
  end

  def convert(value, from:, to:)
    from_unit = unit_for!(from)
    to_unit = unit_for!(to)
    conversion = conversion_table[from][to]

    raise Measured::UnitError, "Cannot find conversion entry from #{from} to #{to}" unless conversion

    BigDecimal(value.to_r * conversion,ARBITRARY_CONVERSION_PRECISION)
  end

  private

  def conversion_table
    @conversion_table ||= Measured::ConversionTable.build(@units)
  end

  def unit_for(name)
    unit = @units.find { |unit| unit.names_include?(name, case_sensitive: @case_sensitive) }
  end

  def unit_for!(name)
    unit_for(name) or raise Measured::UnitError, "Cannot find unit for #{name}"
  end
end
