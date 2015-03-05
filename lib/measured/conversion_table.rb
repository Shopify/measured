class Measured::ConversionTable

  def initialize(units)
    @units = units
  end

  def to_h
    table = {}

    @units.map{|u| u.name}.each do |to_unit|
      to_table = {to_unit => BigDecimal("1")}

      table.each do |from_unit, from_table|
        to_table[from_unit] = find_conversion(to: from_unit, from: to_unit)
        from_table[to_unit] = find_conversion(to: to_unit, from: from_unit)
      end

      table[to_unit] = to_table
    end

    table
  end

  private

  def find_conversion(to:, from:)
    conversion = find_direct_conversion(to: to, from: from) || find_tree_traversal_conversion(to: to, from: from)

    raise Measured::UnitError, "Cannot find conversion path from #{ from } to #{ to }." unless conversion

    conversion
  end

  def find_direct_conversion(to:, from:)
    @units.each do |unit|
      return unit.conversion_amount if unit.name == from && unit.conversion_unit == to
    end

    @units.each do |unit|
      return unit.inverse_conversion_amount if unit.name == to && unit.conversion_unit == from
    end

    nil
  end

  def find_tree_traversal_conversion(to:, from:)
    traverse(from: from, to: to, unit_names: @units.map{|u| u.name }, amount: BigDecimal("1"))
  end

  def traverse(from:, to:, unit_names:, amount:)
    unit_names = unit_names - [from]

    unit_names.each do |name|
      if conversion = find_direct_conversion(from: from, to: name)
        if name == to
          return amount * conversion
        else
          result = traverse(from: name, to: to, unit_names: unit_names, amount: amount * conversion)
          return result if result
        end
      end
    end

    nil
  end

end
