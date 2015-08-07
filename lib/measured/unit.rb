class Measured::Unit
  include Comparable

  def initialize(name, aliases: [], case_sensitive: false, value: nil)
    @name = name.to_s
    @names = ([@name] + aliases.map{|n| n.to_s }).sort

    @case_sensitive = case_sensitive
    @conversion_amount, @conversion_unit = parse_value(value) if value
  end

  attr_reader :name, :names, :case_sensitive, :conversion_amount, :conversion_unit

  def name_eql?(name_to_compare)
    with_case_sensitivity(self.name).include?(with_case_sensitivity(name_to_compare).join)
  end

  def names_include?(name_to_compare)
    with_case_sensitivity(self.names).include?(with_case_sensitivity(name_to_compare).join)
  end

  def add_alias(aliases)
    @names = (@names << aliases).flatten.sort
  end

  def to_s
    if conversion_string
      "#{ @name } (#{ conversion_string })"
    else
      @name
    end
  end

  def inspect
    "#<Measured::Unit: #{ @name } (#{ @names.join(", ") }) #{ conversion_string }>"
  end

  def <=>(other)
    if self.class == other.class
      if other.names != @names
        other.names <=> @names
      else
        other.conversion_amount <=> @conversion_amount
      end
    else
      @name <=> other
    end
  end

  def inverse_conversion_amount
    1 / conversion_amount.to_r
  end

  private

  def with_case_sensitivity(comparison)
    comparison = [comparison].flatten
    case_sensitive ? comparison : comparison.map(&:downcase)
  end

  def conversion_string
    "#{ conversion_amount } #{ conversion_unit }" if @conversion_amount || @conversion_unit
  end

  def parse_value(tokens)
    tokens = tokens.split(" ") if tokens.is_a?(String)
    raise Measured::UnitError, "Cannot parse 'number unit' or [number, unit] formatted tokens from #{ tokens }." unless tokens.size == 2

    tokens[0] = BigDecimal(tokens[0]) unless tokens[0].is_a?(BigDecimal) || tokens[0].is_a?(Rational)

    tokens
  end
end
