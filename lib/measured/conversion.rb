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
    @units.map{|u| u.names}.flatten.sort
  end

  def unit_names
    @units.map{|u| u.name}.sort
  end

  def unit_or_alias?(name)
    @units.each{|unit| return true if unit.names_include?(name, case_sensitive: @case_sensitive)}
    false
  end

  def unit?(name)
    @units.each{|unit| return true if unit.name_eql?(name, case_sensitive: @case_sensitive)}
    false
  end

  def to_unit_name(name)
    unit_for(name).name
  end

  def convert(value, from:, to:)
    raise Measured::UnitError, "Source unit #{ from } does not exits." unless unit?(from)
    raise Measured::UnitError, "Converted unit #{ to } does not exits." unless unit?(to)

    from_unit = unit_for(from)
    to_unit = unit_for(to)

    raise Measured::UnitError, "Cannot find conversion entry from #{ from } to #{ to }" unless conversion = conversion_table[from][to]

    BigDecimal(value.to_r * conversion,ARBITRARY_CONVERSION_PRECISION)
  end

  def conversion_table
    @conversion_table ||= Measured::ConversionTable.build(@units)
  end

  private

  def unit_for(name)
    @units.each do |unit|
      return unit if unit.names_include?(name, case_sensitive: @case_sensitive)
    end

    raise Measured::UnitError, "Cannot find unit for #{ name }."
  end
end
