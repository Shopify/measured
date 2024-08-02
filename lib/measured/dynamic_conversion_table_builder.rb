# frozen_string_literal: true
module Measured
  class DynamicConversionTableBuilder < ConversionTableBuilder
    SELF_CONVERSION = ->(x) { x * Rational(1, 1) }

    private

    def after_initialize
      @units.map!(&:to_dynamic)
      validate_cache
    end

    def validate_cache
      return if @cache.is_a?(Measured::Cache::Null)

      raise CacheError, "Dynamic unit systems cannot be cached"
    end

    def generate_table
      validate_no_cycles

      units.map(&:name).each_with_object({}) do |to_unit, table|
        to_table = {to_unit => SELF_CONVERSION}

        table.each do |from_unit, from_table|
          conversion, inverse_conversion = find_conversion(to: from_unit, from: to_unit)
          to_table[from_unit] = conversion
          from_table[to_unit] = inverse_conversion
        end

        table[to_unit] = to_table
      end
    end

    def find_direct_conversion(to:, from:)
      units.each do |unit|
        if unit.name == from && unit.conversion_unit == to
          return [unit.conversion_amount, unit.inverse_conversion_amount]
        end

        if unit.name == to && unit.conversion_unit == from
          return [unit.inverse_conversion_amount, unit.conversion_amount]
        end
      end

      nil
    end

    def find_tree_traversal_conversion(to:, from:)
      traverse(from: from, to: to, units_remaining: units.map(&:name), amount: ->(x) { x }, inverse_amount: ->(x) { x })
    end

    def traverse(from:, to:, units_remaining:, amount:, inverse_amount:)
      units_remaining = units_remaining - [from]

      units_remaining.each do |name|
        conversion, inverse_conversion = find_direct_conversion_cached(from: from, to: name)

        if conversion
          new_amount = ->(x) { conversion.call amount.call(x) }
          new_inverse_amount = ->(x) { inverse_amount.call inverse_conversion.call(x) }

          if name == to
            return [new_amount, new_inverse_amount]
          else
            result = traverse(from: name, to: to, units_remaining: units_remaining, amount: new_amount, inverse_amount: new_inverse_amount)
            return result if result
          end
        end
      end

      nil
    end
  end
end
