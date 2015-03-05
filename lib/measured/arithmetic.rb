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

  def -@
    self.class.new(-self.value, self.unit)
  end

  def coerce(other)
    [self, other]
  end

  private

  def arithmetic_operation(other, operator)
    if other.is_a?(self.class)
      self.class.new(self.value.send(operator, other.convert_to(self.unit).value), self.unit)
    elsif other.is_a?(Numeric)
      self.class.new(self.value.send(operator, other), self.unit)
    else
      raise TypeError, "Invalid operation #{ operator } between #{ self.class } to #{ other.class }"
    end
  end
end
