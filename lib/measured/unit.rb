# frozen_string_literal: true
class Measured::Unit
  include Comparable

  attr_reader :name, :names, :aliases, :unit_system, :unit_conversion

  def initialize(name, aliases: [], value: nil, unit_system: nil)
    @name = name.to_s.freeze
    @aliases = aliases.map(&:to_s).map(&:freeze).freeze
    @names = ([@name] + @aliases).sort!.freeze
    @unit_conversion = Measured::UnitConversion.parse(value)
    @unit_system = unit_system
  end

  def with(name: nil, unit_system: nil, aliases: nil, value: nil)
    value ||= @unit_conversion.to_s
    if dynamic?
      value = @unit_conversion.value
    end

    self.class.new(
      name || self.name,
      aliases: aliases || self.aliases,
      value: value,
      unit_system: unit_system || self.unit_system
    )
  end

  def to_s(with_conversion_string: true)
    if with_conversion_string && @unit_conversion.to_s
      "#{name} (#{@unit_conversion})".freeze
    else
      name
    end
  end

  def inspect
    pieces = [name]
    pieces << "(#{aliases.join(", ")})" if aliases.any?
    pieces << @unit_conversion if @unit_conversion.to_s
    "#<#{self.class.name}: #{pieces.join(" ")}>".freeze
  end

  def <=>(other)
    if self.class == other.class
      names_comparison = names <=> other.names
      if names_comparison != 0
        names_comparison
      else
        compared_value(conversion_amount) <=> compared_value(other.conversion_amount)
      end
    else
      name <=> other
    end
  end

  def conversion_unit
    @unit_conversion.unit
  end

  def conversion_amount
    @unit_conversion.amount
  end

  def inverse_conversion_amount
    @unit_conversion.inverse_amount
  end

  def dynamic?
    @unit_conversion.dynamic?
  end

  def to_dynamic
    @unit_conversion = @unit_conversion.to_dynamic
    self
  end

  private

  def compared_value(conversion_amount)
    case conversion_amount
    when Proc
      conversion_amount.call(1)
    else
      conversion_amount
    end
  end
end
