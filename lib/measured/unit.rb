# frozen_string_literal: true
class Measured::Unit
  include Comparable

  attr_reader :name, :names, :aliases, :conversion_amount, :conversion_unit, :unit_system, :inverse_conversion_amount, :description

  def initialize(name, aliases: [], value: nil, unit_system: nil)
    @name = name.to_s.freeze
    @aliases = aliases.map(&:to_s).map(&:freeze).freeze
    @names = ([@name] + @aliases).sort!.freeze
    @conversion_amount, @conversion_unit = parse_value(value) if value
    @inverse_conversion_amount ||= compute_inverse(@conversion_amount)
    @conversion_string = build_conversion_string
    @unit_system = unit_system
  end

  def with(name: nil, unit_system: nil, aliases: nil, value: nil)
    self.class.new(
      name || self.name,
      aliases: aliases || self.aliases,
      value: value || @raw_value,
      unit_system: unit_system || self.unit_system
    )
  end

  def functional?
    @conversion_amount.is_a?(Proc)
  end

  def to_s(with_conversion_string: true)
    if with_conversion_string && @conversion_string
      "#{name} (#{@conversion_string})".freeze
    else
      name
    end
  end

  def inspect
    pieces = [name]
    pieces << "(#{aliases.join(", ")})" if aliases.any?
    pieces << @conversion_string if @conversion_string
    "#<#{self.class.name}: #{pieces.join(" ")}>".freeze
  end

  def <=>(other)
    if self.class == other.class
      names_comparison = names <=> other.names
      if names_comparison != 0
        names_comparison
      else
        comparable_amount(conversion_amount) <=> comparable_amount(other.conversion_amount)
      end
    else
      name <=> other
    end
  end

  private

  def comparable_amount(amount)
    amount.is_a?(Proc) ? amount.call(Rational(1)) : amount
  end

  def compute_inverse(amount)
    return nil unless amount

    1 / amount
  end

  def build_conversion_string
    return nil unless @conversion_amount || @conversion_unit

    if @conversion_amount.is_a?(Proc)
      @description
    else
      "#{@conversion_amount} #{@conversion_unit}"
    end
  end

  def parse_value(tokens)
    case tokens
    when String
      parsed = Measured::Parser.parse_string(tokens)
      @raw_value = tokens
      [parsed[0].to_r, parsed[1].freeze]
    when Array
      raise Measured::UnitError, "Cannot parse [number, unit] formatted tokens from #{tokens}." unless tokens.size == 2

      if tokens[0].is_a?(Hash)
        parse_functional_value(tokens)
      else
        @raw_value = tokens
        [tokens[0].to_r, tokens[1].to_s.freeze]
      end
    else
      raise Measured::UnitError, "Unit must be defined as string or array, but received #{tokens}"
    end
  end

  def parse_functional_value(tokens)
    opts = tokens[0]
    forward = opts.fetch(:forward)
    backward = opts.fetch(:backward)
    @description = opts.fetch(:description) { raise Measured::UnitError, "description is required for functional conversions" }
    @raw_value = tokens
    @inverse_conversion_amount = backward

    [forward, tokens[1].to_s.freeze]
  end
end
