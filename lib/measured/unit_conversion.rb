# frozen_string_literal: true

module Measured
  class UnitConversion
    def self.parse(tokens, description: nil)
      if tokens.nil?
        return StaticUnitConversion.new(amount: nil, unit: nil)
      end

      case tokens
      when String
        tokens = Measured::Parser.parse_string(tokens)
      when Array
        raise Measured::UnitError, "Cannot parse [number, unit] formatted tokens from #{tokens}." unless tokens.size == 2
      else
        raise Measured::UnitError, "Unit must be defined as string or array, but received #{tokens}"
      end

      case tokens[0]
      when Hash
        DynamicUnitConversion.new(
          amount: tokens[0][:conversion],
          inverse_amount: tokens[0][:reverse_conversion],
          description: tokens[0][:description],
          unit: tokens[1].freeze
        )
      else
        StaticUnitConversion.new(
          amount: tokens[0].to_r,
          unit: tokens[1].freeze
        )
      end
    end
  end

  class DynamicUnitConversion
    attr_reader :amount, :inverse_amount, :unit

    def initialize(amount:, inverse_amount:, unit:, description: nil)
      @amount = amount
      @inverse_amount = inverse_amount
      @unit = unit
      @description = description
    end

    def value
      [
        {
          conversion: amount,
          reverse_conversion: inverse_amount,
          description: @description
        },
        unit
      ]
    end

    def dynamic?
      true
    end

    def static?
      false
    end

    def to_s
      @description
    end

    def to_dynamic
      self
    end
  end

  class StaticUnitConversion
    attr_reader :amount, :unit

    def initialize(amount:, unit:)
      @amount = amount
      @unit = unit
    end

    def dynamic?
      false
    end

    def static?
      true
    end

    def to_s
      return unless amount && unit

      "#{amount} #{unit}"
    end

    def inverse_amount
      return unless amount

      (1 / amount)
    end

    def to_dynamic
      DynamicUnitConversion.new(
        amount: ->(x) { x * amount },
        inverse_amount: ->(x) { x * inverse_amount },
        unit: unit,
        description: to_s
      )
    end
  end
end
