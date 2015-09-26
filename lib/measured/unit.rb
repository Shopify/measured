class Measured::Unit
  include Comparable

  def initialize(name, aliases: [], value: nil)
    @name = name.to_s
    @names = ([@name] + aliases.map{|n| n.to_s }).sort

    @conversion_amount, @conversion_unit = parse_value(value) if value
  end

  attr_reader :name, :names, :conversion_amount, :conversion_unit

  def name_eql?(name_to_compare, case_sensitive: false)
    return false unless name_to_compare.present?
    name_to_compare = name_to_compare.to_s
    case_sensitive ? @name.eql?(name_to_compare) : case_insensitive(@name).include?(name_to_compare.downcase)
  end

  def names_include?(name_to_compare, case_sensitive: false)
    return false unless name_to_compare.present?
    name_to_compare = name_to_compare.to_s
    case_sensitive ? @names.include?(name_to_compare) : case_insensitive(@names).include?(name_to_compare.downcase)
  end

  def add_alias(aliases)
    @names = (@names << aliases).flatten.sort unless aliases.nil? || aliases.empty?
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

  def case_insensitive(comparison)
    [comparison].flatten.map(&:downcase)
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
