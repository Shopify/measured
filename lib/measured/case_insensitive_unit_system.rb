class Measured::CaseInsensitiveUnitSystem < Measured::BaseUnitSystem
  def unit?(name)
    super(name.to_s.downcase)
  end

  def unit_for(name)
    unit_name_to_unit[name.to_s.downcase]
  end
end
