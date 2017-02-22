class Measured::Unit
  include Comparable

  attr_reader :name, :aliases, :conversion_amount, :conversion_unit, :unit_system

  def initialize(name, aliases: [], value: nil, unit_system: nil)
    @name = name.to_s.freeze
    @aliases = aliases.map(&:to_s).map(&:freeze).freeze
    @conversion_amount, @conversion_unit = parse_value(value) if value
    @unit_system = unit_system
  end

  def with_unit_system(unit_system)
    self.class.new(
      name,
      aliases: aliases,
      value: conversion_string,
      unit_system: unit_system
    )
  end

  def names
    @names ||= ([name] + aliases).sort!.freeze
  end

  def to_s
    @to_s ||= if conversion_string
      "#{name} (#{conversion_string})".freeze
    else
      name
    end
  end

  def inspect
    @inspect ||= begin
      pieces = [name]
      pieces << "(#{aliases.join(", ")})" if aliases.any?
      pieces << conversion_string if conversion_string
      "#<#{self.class.name}: #{pieces.join(" ")}>".freeze
    end
  end

  def <=>(other)
    if self.class == other.class
      names_comparison = names <=> other.names
      if names_comparison != 0
        names_comparison
      else
        conversion_amount <=> other.conversion_amount
      end
    else
      name <=> other
    end
  end

  def inverse_conversion_amount
    @inverse_conversion_amount ||= 1 / conversion_amount
  end

  private

  def conversion_string
    @conversion_string ||= ("#{conversion_amount} #{conversion_unit}" if conversion_amount || conversion_unit)
  end

  def parse_value(tokens)
    case tokens
    when String
      tokens = Measured::Parser.parse_string(tokens)
    when Array
      raise Measured::UnitError, "Cannot parse [number, unit] formatted tokens from #{tokens}." unless tokens.size == 2
    else
      raise Measured::UnitError, "Unit must be defined as string or array, but received #{tokens}"
    end

    [tokens[0].to_r, tokens[1].freeze]
  end
end
