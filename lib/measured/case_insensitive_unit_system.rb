class Measured::CaseInsensitiveUnitSystem < Measured::UnitSystem
  def unit?(name)
    super(name.to_s.downcase)
  end

  protected

  def unit_for(name)
    unit_name_to_unit[name.to_s.downcase]
  end
end
