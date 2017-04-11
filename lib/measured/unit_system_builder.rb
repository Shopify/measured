class Measured::UnitSystemBuilder
  def initialize
    @units = []
  end

  def unit(unit_name, aliases: [], value: nil)
    @units << build_unit(unit_name, aliases: aliases, value: value)
    nil
  end

  def si_unit(unit_name, aliases: [], value: nil)
    @units += build_si_units(unit_name, aliases: aliases, value: value)
    nil
  end

  def build
    Measured::UnitSystem.new(@units)
  end

  private

  def self.prefixes
    [
      ['y', 'yocto', -24],
      ['z', 'zepto', -21],
      ['a', 'atto', -18],
      ['f', 'femto', -15],
      ['p', 'pico', -12],
      ['n', 'nano', -9],
      ['μ', 'micro', -6],
      ['m', 'milli', -3],
      ['c', 'centi', -2],
      ['d', 'deci', -1],
      ['', '', 0],
      ['da', 'deca', 1],
      ['h', 'hecto', 2],
      ['k', 'kilo', 3],
      ['M', 'mega', 6],
      ['G', 'giga', 9],
      ['T', 'tera', 12],
      ['P', 'peta', 15],
      ['E', 'exa', 18],
      ['Z', 'zetta', 21],
      ['Y', 'yotta', 24]
    ]
  end

  def build_si_units(name, aliases: [], value: nil)
    value = "1 #{name}" if !value
    size, unit = value.split(' ')
    size ||= 1
    si_units = []
    self.class.prefixes.each do |short, long, exp|
      long_names = aliases.map {|suffix| "#{long}#{suffix}"}
      value_with_exp = size.to_r * 10 ** exp
      si_units << build_unit("#{short}#{name}", aliases: long_names, value: "#{value_with_exp} #{unit}")
    end
    si_units
  end

  def build_unit(name, aliases: [], value: nil)
    unit = Measured::Unit.new(name, aliases: aliases, value: value)
    check_for_duplicate_unit_names!(unit)
    unit
  end

  def check_for_duplicate_unit_names!(unit)
    names = @units.flat_map(&:names)
    if names.any? { |name| unit.names.include?(name) }
      raise Measured::UnitError, "Unit #{unit.name} has already been added."
    end
  end
end
