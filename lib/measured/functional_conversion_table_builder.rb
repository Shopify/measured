# frozen_string_literal: true
class Measured::FunctionalConversionTableBuilder
  include Measured::ConversionTableBuilderBase

  IDENTITY = ->(x) { x }

  def initialize(units, cache: nil)
    @units = units
    cache ||= { class: Measured::Cache::Null }
    cache_instance = cache[:class].new(*cache[:args])
    unless cache_instance.is_a?(Measured::Cache::Null)
      raise Measured::CacheError, "Functional unit systems cannot be cached"
    end
  end

  def to_h
    @table ||= generate_table
  end

  def update_cache
    raise Measured::CacheError, "Functional unit systems cannot be cached"
  end

  def cached?
    false
  end

  private

  def generate_table
    validate_no_cycles

    units.map(&:name).each_with_object({}) do |to_unit, table|
      to_table = { to_unit => IDENTITY }

      table.each do |from_unit, from_table|
        conversion, inverse = find_conversion(to: from_unit, from: to_unit)
        to_table[from_unit] = conversion
        from_table[to_unit] = inverse
      end

      table[to_unit] = to_table
    end
  end

  def find_conversion(to:, from:)
    result = find_direct_conversion_cached(to: to, from: from) || find_tree_traversal_conversion(to: to, from: from)
    raise Measured::MissingConversionPath.new(from, to) unless result
    result
  end

  def find_direct_conversion(to:, from:)
    units.each do |unit|
      if unit.name == from && unit.conversion_unit == to
        forward = wrap_conversion(unit.conversion_amount)
        backward = wrap_conversion(unit.inverse_conversion_amount)
        return [forward, backward]
      end

      if unit.name == to && unit.conversion_unit == from
        backward = wrap_conversion(unit.conversion_amount)
        forward = wrap_conversion(unit.inverse_conversion_amount)
        return [forward, backward]
      end
    end

    nil
  end

  def wrap_conversion(amount)
    return amount if amount.is_a?(Proc)

    ->(x) { x * amount }
  end

  def find_tree_traversal_conversion(to:, from:)
    identity = ->(x) { x }
    traverse(from: from, to: to, units_remaining: units.map(&:name), forward: identity, backward: identity)
  end

  def traverse(from:, to:, units_remaining:, forward:, backward:)
    units_remaining = units_remaining - [from]

    units_remaining.each do |name|
      pair = find_direct_conversion_cached(from: from, to: name)
      next unless pair

      step_forward, step_backward = pair
      new_forward = compose(step_forward, forward)
      new_backward = compose(backward, step_backward)

      if name == to
        return [new_forward, new_backward]
      else
        result = traverse(from: name, to: to, units_remaining: units_remaining, forward: new_forward, backward: new_backward)
        return result if result
      end
    end

    nil
  end

  def compose(outer, inner)
    ->(x) { outer.call(inner.call(x)) }
  end
end
