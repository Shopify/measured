# frozen_string_literal: true
module Measured::ConversionTableBuilderBase
  attr_reader :units

  private

  def validate_no_cycles
    graph = units.select { |unit| unit.conversion_unit.present? }.group_by(&:name)
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

  def find_direct_conversion_cached(to:, from:)
    @direct_conversion_cache ||= {}
    @direct_conversion_cache[to] ||= {}

    if @direct_conversion_cache[to].key?(from)
      @direct_conversion_cache[to][from]
    else
      @direct_conversion_cache[to][from] = find_direct_conversion(to: to, from: from)
    end
  end
end
