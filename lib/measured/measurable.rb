class Measured::Measurable < Numeric
  include Measured::Arithmetic

  attr_reader :unit, :value, :unit_system

  def initialize(value, unit, unit_system)
    raise Measured::UnitError, "Unit value cannot be blank" if value.blank?

    @unit = unit_from_unit_or_name!(unit)
    @unit_system = unit_system
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
    new_unit = unit_from_unit_or_name!(new_unit)
    return self if new_unit == unit

    new_value = unit.unit_system.convert(value, from: unit, to: new_unit)

    self.class.new(new_value, new_unit)
  end

  def to_s
    @to_s ||= "#{value_string} #{unit}"
  end

  def inspect
    @inspect ||= "#<#{unit_system}: #{value_string} #{unit}>"
  end

  def <=>(other)
    if other.is_a?(self.class)
      value <=> other.convert_to(unit).value
    else
      nil
    end
  end

  private

  def unit_from_unit_or_name!(value)
    value.is_a?(Measured::Unit) ? value : self.class.unit_system.unit_for!(value)
  end

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
