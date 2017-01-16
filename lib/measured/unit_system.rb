class Measured::UnitSystem
  class << self
    def units
      raise "`UnitSystem` does not have a `units` object. You cannot directly subclass `UnitSystem`. Instead, build a new unit system by calling `Measured.build`."
    end

    def new(value, unit)
      Measured::Measurable.new(value, unit, self)
    end

    def unit_names_with_aliases
      @unit_names_with_aliases ||= units.flat_map(&:names).sort
    end

    def unit_names
      @unit_names ||= units.map(&:name).sort
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

      value.to_r * conversion
    end

    def name
      to_s.split("::").last.underscore.humanize.downcase
    end

    protected

    def conversion_table
      @conversion_table ||= Measured::ConversionTable.build(units)
    end

    def unit_name_to_unit
      @unit_name_to_unit ||= units.inject({}) do |hash, unit|
        unit.names.each { |name| hash[name.to_s] = unit }
        hash
      end
    end
  end
end
