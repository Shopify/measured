# frozen_string_literal: true
module Measured::Arithmetic
  extend Forwardable
  def_delegators :@value, :zero?, :positive?, :negative?

  def +(other)
    arithmetic_operation(other, :+)
  end

  def -(other)
    arithmetic_operation(other, :-)
  end

  def -@
    self.class.new(-self.value, self.unit)
  end

  def scale(other)
    self.class.new(self.value * other, self.unit)
  end

  def coerce(other)
    if other.is_a?(self.class)
      [other, self]
    else
      raise TypeError, "Cannot coerce #{other.class} to #{self.class}"
    end
  end

  def to_i
    raise TypeError, "#{self.class} cannot be converted to an integer"
  end

  def nonzero?
    value.nonzero? ? self : false
  end

  private

  def arithmetic_operation(other, operator)
    other, _ = coerce(other)
    self.class.new(self.value.public_send(operator, other.convert_to(self.unit).value), self.unit)
  end
end
