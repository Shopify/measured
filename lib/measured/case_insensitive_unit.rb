class Measured::CaseInsensitiveUnit < Measured::Unit
  def initialize(name, aliases: [], value: nil)
    super(name.to_s.downcase, aliases: aliases.map(&:to_s).map!(&:downcase), value: value)
  end

  def name_eql?(name_to_compare)
    super(name_to_compare.to_s.downcase)
  end

  def names_include?(name_to_compare)
    super(name_to_compare.to_s.downcase)
  end
end
