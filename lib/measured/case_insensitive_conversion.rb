class Measured::CaseInsensitiveConversion < Measured::Conversion
  protected

  def unit_for(name)
    unit_name_to_unit[name.to_s.downcase]
  end
end
