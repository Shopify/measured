class Measured::Conversion
  def initialize
    @base_unit = nil
    @units = []
  end

  attr_reader :base_unit, :units

  def set_base(unit_name, aliases: [])
    add_new_unit(unit_name, aliases: aliases, base: true)
  end

  def add(unit_name, aliases: [], value:)
    add_new_unit(unit_name, aliases: aliases, value: value)
  end

  def unit_names_with_aliases
    @units.map{|u| u.names}.flatten.sort
  end

  def unit_names
    @units.map{|u| u.name}.sort
  end

  def unit_or_alias?(name)
    unit_names_with_aliases.include?(name.to_s)
  end

  def unit?(name)
    unit_names.include?(name.to_s)
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

    value * conversion
  end

  def conversion_table
    @conversion_table ||= Measured::ConversionTable.new(@units).to_h
  end

  private

  def add_new_unit(unit_name, aliases:, value: nil, base: false)
    if base && @base_unit
      raise Measured::UnitError, "Can only have one base unit. Adding #{ unit_name } but already defined #{ @base_unit }."
    elsif !base && !@base_unit
      raise Measured::UnitError, "A base unit has not yet been set."
    end

    check_for_duplicate_unit_names([unit_name] + aliases)

    unit = Measured::Unit.new(unit_name, aliases: aliases, value: value)
    @units << unit
    @base_unit = unit if base

    clear_conversion_table

    unit
  end

  def check_for_duplicate_unit_names(names)
    names.each do |name|
      raise Measured::UnitError, "Unit #{ name } has already been added." if unit_or_alias?(name)
    end
  end

  def unit_for(name)
    @units.each do |unit|
      return unit if unit.names.include?(name.to_s)
    end

    raise Measured::UnitError, "Cannot find unit for #{ name }."
  end

  def clear_conversion_table
    @conversion_table = nil
  end

end
