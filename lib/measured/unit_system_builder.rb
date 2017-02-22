class Measured::UnitSystemBuilder
  def initialize
    @units = []
  end

  def unit(unit_name, aliases: [], value: nil)
    @units << build_unit(unit_name, aliases: aliases, value: value)
    nil
  end

  def build
    Measured::UnitSystem.new(@units)
  end

  private

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
