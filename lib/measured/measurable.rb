# frozen_string_literal: true
class Measured::Measurable < Numeric
  DEFAULT_FORMAT_STRING = "%.2<value>f %<unit>s"

  include Measured::Arithmetic

  attr_reader :unit, :value

  def initialize(value, unit)
    raise Measured::UnitError, "Unit value cannot be blank" if value.blank?

    @unit = unit_from_unit_or_name!(unit)
    @value = case value
    when Float
      BigDecimal(value, Float::DIG)
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

  def format(format_string=nil)
    kwargs = {
      value: self.value,
      unit: self.unit,
    }
    (format_string || DEFAULT_FORMAT_STRING) % kwargs
  end

  def to_s
    @to_s ||= "#{value_string} #{unit.name}"
  end

  def humanize
    @humanize ||= begin
      unit_string = value == 1 ? unit.name : ActiveSupport::Inflector.pluralize(unit.name)
      "#{value_string} #{unit_string}"
    end
  end

  def inspect
    @inspect ||= "#<#{self.class}: #{value_string} #{unit.inspect}>"
  end

  def <=>(other)
    if other.is_a?(self.class)
      value <=> other.convert_to(unit).value
    else
      nil
    end
  end

  class << self
    extend Forwardable

    def unit_system
      raise "`Measurable` does not have a `unit_system` object. You cannot directly subclass `Measurable`. Instead, build a new unit system by calling `Measured.build`."
    end

    delegate unit_names: :unit_system
    delegate unit_names_with_aliases: :unit_system
    delegate unit_or_alias?: :unit_system

    def name
      to_s.split("::").last.underscore.humanize.downcase
    end

    def parse(string)
      new(*Measured::Parser.parse_string(string))
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
