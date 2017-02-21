class Measured::Unit < Measured::BaseUnit
  def initialize(name, aliases: [], value: nil, unit_system: nil)
    super(
      name.to_s.downcase,
      aliases: aliases.map(&:to_s).map!(&:downcase),
      value: value,
      unit_system: unit_system
    )
  end

  private

  def parse_value(tokens)
    value, unit = super
    [value, unit.downcase]
  end
end
