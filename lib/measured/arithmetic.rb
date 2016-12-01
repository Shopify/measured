module Measured::Arithmetic
  def +(other)
    arithmetic_operation(other, :+)
  end

  def -(other)
    arithmetic_operation(other, :-)
  end

  def *(other)
    arithmetic_operation(other, :*)
  end

  def /(other)
    arithmetic_operation(other, :/)
  end

  def coerce(other)
    case other
    when self.class
      [other, self]
    when Numeric
      [self.class.new(other, self.unit), self]
    else
      raise TypeError, "Cannot coerce #{other.class} to #{self.class}"
    end
  end

  def to_i
    raise TypeError, "#{self.class} cannot be converted to an integer"
  end

  private

  def arithmetic_operation(other, operator)
    other, _ = coerce(other)
    self.class.new(self.value.public_send(operator, other.convert_to(self.unit).value), self.unit)
  end
end
