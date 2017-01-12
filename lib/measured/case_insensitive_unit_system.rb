class Measured::CaseInsensitiveConversion < Measured::Conversion
  def unit?(name)
    super(name.to_s.downcase)
  end

  protected

  def unit_for(name)
    unit_name_to_unit[name.to_s.downcase]
  end
end
