class Measured::Measurable < Numeric
  include Measured::Arithmetic

  attr_reader :unit, :value

  def initialize(value, unit)
    raise Measured::UnitError, "Unit cannot be blank" if unit.blank?
    raise Measured::UnitError, "Unit #{ unit } does not exist" unless self.class.conversion.unit_or_alias?(unit)

    @value = case value
    when NilClass
      raise Measured::UnitError, "Unit value cannot be nil"
    when Float
      BigDecimal(value, Float::DIG+1)
    when BigDecimal
      value
    else
      if value.blank?
        raise Measured::UnitError, "Unit value cannot be blank"
      else
        BigDecimal(value)
      end
    end

    @unit = self.class.conversion.to_unit_name(unit)
  end

  def convert_to(new_unit)
    new_unit_name = self.class.conversion.to_unit_name(new_unit)
    return self if new_unit_name == self.class.conversion.to_unit_name(unit)

    value = self.class.conversion.convert(@value, from: @unit, to: new_unit_name)

    self.class.new(value, new_unit)
  end

  def to_s
    [value.to_f.to_s.gsub(/\.0\Z/, ""), unit].join(" ")
  end

  def inspect
    "#<#{ self.class }: #{ value } #{ unit }>"
  end

  def <=>(other)
    case other
    when self.class
      value <=> other.convert_to(unit).value
    when 0
      value <=> 0
    end
  end

  class << self

    def conversion
      @conversion ||= Measured::Conversion.new
    end

    def units
      conversion.unit_names
    end

    def valid_unit?(unit)
      conversion.unit_or_alias?(unit)
    end

    def units_with_aliases
      conversion.unit_names_with_aliases
    end

    def name
      to_s.split("::").last.underscore.humanize.downcase
    end

  end
end
