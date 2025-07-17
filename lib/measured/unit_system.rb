# frozen_string_literal: true
class Measured::UnitSystem
  attr_reader :units, :unit_names, :unit_names_with_aliases

  def initialize(units, cache: nil)
    @units = units.map { |unit| unit.with(unit_system: self) }
    @units = @units.map do |unit|
      next unit unless unit.conversion_unit
      conversion_unit = @units.find { |u| u.names.include?(unit.conversion_unit) }
      next unit unless conversion_unit
      unit.with(value: [unit.conversion_amount, conversion_unit.name])
    end
    @unit_names = @units.map(&:name).sort.freeze
    @unit_names_with_aliases = @units.flat_map(&:names).sort.freeze
    @unit_name_to_unit = @units.each_with_object({}) do |unit, hash|
      unit.names.each { |name| hash[name.to_s] = unit }
    end

    table_builder = Measured::ConversionTableBuilder
    if @units.any?(&:dynamic?)
      table_builder = Measured::DynamicConversionTableBuilder
    end

    @conversion_table_builder = table_builder.new(@units, cache: cache)
    @conversion_table = @conversion_table_builder.to_h.freeze
  end

  def unit_or_alias?(name)
    !!unit_for(name)
  end

  def unit?(name)
    unit = unit_for(name)
    unit ? unit.name == name.to_s : false
  end

  def unit_for(name)
    unit_name_to_unit[name.to_s]
  end

  def unit_for!(name)
    unit = unit_for(name)
    raise Measured::UnitError, "Unit '#{name}' does not exist" unless unit
    unit
  end

  def convert(value, from:, to:)
    conversion = conversion_table.fetch(from.name, {})[to.name]

    raise Measured::UnitError, "Cannot find conversion entry from #{from} to #{to}" unless conversion
    case conversion
    when Proc
      conversion.call(value).to_r
    else
      value.to_r * conversion
    end
  end

  def update_cache
    @conversion_table_builder.update_cache
  end

  def cached?
    @conversion_table_builder.cached?
  end

  protected

  attr_reader :unit_name_to_unit, :conversion_table
end
