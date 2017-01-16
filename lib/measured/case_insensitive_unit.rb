class Measured::CaseInsensitiveUnit < Measured::Unit
  def initialize(name, aliases: [], value: nil)
    super(name.to_s.downcase, aliases: aliases.map(&:to_s).map!(&:downcase), value: value)
  end
end
