module Measured::ConversionTable
  extend self

  def build(units)
    table = {}

    units.map{|u| u.name}.each do |to_unit|
      to_table = {to_unit => BigDecimal("1")}

      table.each do |from_unit, from_table|
        to_table[from_unit] = find_conversion(units, to: from_unit, from: to_unit)
        from_table[to_unit] = find_conversion(units, to: to_unit, from: from_unit)
      end

      table[to_unit] = to_table
    end

    table
  end

  private

  def find_conversion(units, to:, from:)
    conversion = find_direct_conversion(units, to: to, from: from) || find_tree_traversal_conversion(units, to: to, from: from)

    raise Measured::UnitError, "Cannot find conversion path from #{ from } to #{ to }." unless conversion

    conversion
  end

  def find_direct_conversion(units, to:, from:)
    units.each do |unit|
      return unit.conversion_amount if unit.name == from && unit.conversion_unit == to
    end

    units.each do |unit|
      return unit.inverse_conversion_amount if unit.name == to && unit.conversion_unit == from
    end

    nil
  end

  def find_tree_traversal_conversion(units, to:, from:)
    traverse(units, from: from, to: to, unit_names: units.map(&:name), amount: 1)
  end

  def traverse(units, from:, to:, unit_names:, amount:)
    unit_names = unit_names - [from]

    unit_names.each do |name|
      if conversion = find_direct_conversion(units, from: from, to: name)
        new_amount = amount * conversion
        if name == to
          return new_amount
        else
          result = traverse(units, from: name, to: to, unit_names: unit_names, amount: new_amount)
          return result if result
        end
      end
    end

    nil
  end

end
