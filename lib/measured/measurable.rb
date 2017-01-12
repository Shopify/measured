class Measured::Measurable < Numeric
  include Measured::Arithmetic

  attr_reader :unit, :value

  def initialize(value, unit)
    raise Measured::UnitError, "Unit value cannot be blank" if value.blank?

    @unit = self.class.unit_system.to_unit_name!(unit)
    @value = case value
    when Float
      BigDecimal(value, Float::DIG + 1)
    when BigDecimal, Rational
      value
    when Integer
      Rational(value)
    else
      BigDecimal(value)
    end
  end

  def convert_to(new_unit)
    new_unit_name = self.class.unit_system.to_unit_name(new_unit)
    return self if new_unit_name == @unit

    value = self.class.unit_system.convert(@value, from: @unit, to: new_unit_name)

    self.class.new(value, new_unit)
  end

  def to_s
    @to_s ||= "#{value_string} #{unit}"
  end

  def inspect
    @inspect ||= "#<#{self.class}: #{value_string} #{unit}>"
  end

  def <=>(other)
    if other.is_a?(self.class)
      value <=> other.convert_to(unit).value
    else
      nil
    end
  end

  class << self

    def unit_system
      raise "`Measurable` does not have a `unit_system` object. You cannot directly subclass `Measurable`. Instead, build a new unit system by calling `Measured.build`."
    end

    def units
      unit_system.unit_names
    end

    def valid_unit?(unit)
      unit_system.unit_or_alias?(unit)
    end

    def units_with_aliases
      unit_system.unit_names_with_aliases
    end

    def name
      to_s.split("::").last.underscore.humanize.downcase
    end

  end

  private

  def value_string
    @value_string ||= begin
      str = case value
      when Rational
        value.denominator == 1 ? value.numerator.to_s : value.to_f.to_s
      when BigDecimal
        value.to_s("F")
      else
        value.to_f.to_s
      end
      str.gsub(/\.0*\Z/, "")
    end
  end
end
