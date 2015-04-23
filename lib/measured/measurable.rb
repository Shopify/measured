class Measured::Measurable
  include Comparable
  include Measured::Arithmetic

  attr_reader :unit, :value

  def initialize(value, unit)
    raise Measured::UnitError, "Unit #{ unit } does not exits." unless self.class.conversion.unit_or_alias?(unit)

    @value = case value
    when Float
      BigDecimal(value, self.class.conversion.significant_digits)
    when BigDecimal
      value
    else
      BigDecimal(value)
    end

    @unit = self.class.conversion.to_unit_name(unit)
  end

  def convert_to(new_unit)
    new_unit_name = self.class.conversion.to_unit_name(new_unit)
    value = self.class.conversion.convert(@value, from: @unit, to: new_unit_name)

    self.class.new(value, new_unit)
  end

  def convert_to!(new_unit)
    converted = convert_to(new_unit)

    @value = converted.value
    @unit = converted.unit

    self
  end

  def to_i
    Kernel.Integer(value)
  end

  def to_f
    Kernel.Float(value)
  end

  def to_s
    [value.to_f.to_s.gsub(/\.0\Z/, ""), unit].join(" ")
  end

  def inspect
    "#<#{ self.class }: #{ value } #{ unit }>"
  end

  def <=>(other)
    if other.is_a?(self.class) && unit == other.unit
      value <=> other.value
    end
  end

  def ==(other)
    !!(other.is_a?(self.class) && unit == other.unit && value == other.value)
  end

  alias_method :eql?, :==

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

  end
end
