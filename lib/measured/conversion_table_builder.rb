# frozen_string_literal: true
class Measured::ConversionTableBuilder
  attr_reader :units

  def initialize(units, cache: nil)
    @units = units
    cache ||= { class: Measured::Cache::Null }
    @cache = cache[:class].new(*cache[:args])
  end

  def to_h
    return @cache.read if cached?
    generate_table
  end

  def update_cache
    @cache.write(generate_table)
  end

  def cached?
    @cache.exist?
  end

  private

  def generate_table
    validate_no_cycles

    units.map(&:name).each_with_object({}) do |to_unit, table|
      to_table = {to_unit => Rational(1, 1)}

      table.each do |from_unit, from_table|
        conversion = find_conversion(to: from_unit, from: to_unit)
        to_table[from_unit] = conversion
        from_table[to_unit] = 1 / conversion
      end

      table[to_unit] = to_table
    end
  end

  def validate_no_cycles
    graph = units.select { |unit| unit.conversion_unit.present? }.group_by { |unit| unit.name }
    validate_acyclic_graph(graph, from: graph.keys[0])
  end

  # This uses a depth-first search algorithm: https://en.wikipedia.org/wiki/Depth-first_search
  def validate_acyclic_graph(graph, from:, visited: [])
    graph[from]&.each do |edge|
      adjacent_node = edge.conversion_unit
      if visited.include?(adjacent_node)
        raise Measured::CycleDetected.new(edge)
      else
        validate_acyclic_graph(graph, from: adjacent_node, visited: visited + [adjacent_node])
      end
    end
  end

  def find_conversion(to:, from:)
    conversion = find_direct_conversion_cached(to: to, from: from) || find_tree_traversal_conversion(to: to, from: from)

    raise Measured::MissingConversionPath.new(from, to) unless conversion

    conversion
  end

  def find_direct_conversion_cached(to:, from:)
    @direct_conversion_cache ||= {}
    @direct_conversion_cache[to] ||= {}

    if @direct_conversion_cache[to].key?(from)
       @direct_conversion_cache[to][from]
    else
      @direct_conversion_cache[to][from] = find_direct_conversion(to: to, from: from)
    end
  end

  def find_direct_conversion(to:, from:)
    units.each do |unit|
      return unit.conversion_amount if unit.name == from && unit.conversion_unit == to
      return unit.inverse_conversion_amount if unit.name == to && unit.conversion_unit == from
    end

    nil
  end

  def find_tree_traversal_conversion(to:, from:)
    traverse(from: from, to: to, units_remaining: units.map(&:name), amount: 1)
  end

  def traverse(from:, to:, units_remaining:, amount:)
    units_remaining = units_remaining - [from]

    units_remaining.each do |name|
      conversion = find_direct_conversion_cached(from: from, to: name)

      if conversion
        new_amount = amount * conversion
        if name == to
          return new_amount
        else
          result = traverse(from: name, to: to, units_remaining: units_remaining, amount: new_amount)
          return result if result
        end
      end
    end

    nil
  end
end
