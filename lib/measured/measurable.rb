class Measured::Measurable < Numeric
  include Measured::Arithmetic

  attr_reader :unit, :value

  def initialize(value, unit)
    raise Measured::UnitError, "Unit '#{unit}' does not exist" unless self.class.conversion.unit_or_alias?(unit)
    raise Measured::UnitError, "Unit value cannot be blank" if value.blank?

    @value = BigDecimal(value, value.is_a?(Float) ? Float::DIG + 1 : 0)
    @unit = self.class.conversion.to_unit_name(unit)
  end

  def convert_to(new_unit)
    new_unit_name = self.class.conversion.to_unit_name(new_unit)
    return self if new_unit_name == self.class.conversion.to_unit_name(unit)

    value = self.class.conversion.convert(@value, from: @unit, to: new_unit_name)

    self.class.new(value, new_unit)
  end

  def to_s
    [value.to_f.to_s.gsub(/\.0\Z/, ""), unit].join(" ")
  end

  def inspect
    "#<#{ self.class }: #{ value } #{ unit }>"
  end

  def <=>(other)
    if other.is_a?(self.class)
      value <=> other.convert_to(unit).value
    else
      nil
    end
  end

  class << self

    def conversion
      raise "`Measurable` does not have a `conversion` object. You cannot directly subclass `Measurable`. Instead, build a new unit system by calling `Measured.build`."
    end

    def units
      conversion.unit_names
    end

    def valid_unit?(unit)
      conversion.unit_or_alias?(unit)
    end

    def units_with_aliases
      conversion.unit_names_with_aliases
    end

    def name
      to_s.split("::").last.underscore.humanize.downcase
    end

  end
end
