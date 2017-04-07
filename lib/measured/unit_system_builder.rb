class Measured::UnitSystemBuilder
  def initialize
    @units = []
  end

  def unit(unit_name, aliases: [], value: nil)
    @units << build_unit(unit_name, aliases: aliases, value: value)
    nil
  end

  def si_unit(unit_name, aliases: [], value: nil, range: range = 3)
    @units += build_si_units(unit_name, aliases: aliases, value: value, range: range)
    nil
  end

  def build
    Measured::UnitSystem.new(@units)
  end

  private

  def build_si_units(name, aliases: [], value: nil)
    si_units = []
    get_positive_prefixes(range).each_with_index do |prefix, index|
      si_units << build_si_unit(prefix + name, concat_prefixes(aliases, prefix), value * power(index))
    end

    get_negative_prefixes(range).each_with_index do |prefix, index|
      si_units << build_si_unit(prefix + name, concat_prefixes(aliases, prefix), value * power(index, -1))
    end

    si_units
  end

  def build_si_unit(name, aliases: [], value: nil)
    unit = Measured::Unit.new(name, aliases: aliases, value: value)
    check_for_duplicate_unit_names!(unit)
    unit
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

  def get_positive_prefixes(range)
    [:k, :M, :G, :T, :P, :E].first(range)
  end

  def get_negative_prefixes(range)
    [:m, :μ, :n, :p, :f, :a].first(range)
  end

  def power(value, sign = 1)
    10 ** (value * 3 * sign)
  end

  def concat_prefixes(aliases: [], prefix: prefix = nil)
    aliases.map {|name| prefix + name}
  end
end
