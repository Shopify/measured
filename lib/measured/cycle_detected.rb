# frozen_string_literal: true
module Measured
  class CycleDetected < UnitError
    attr_reader :unit

    def initialize(unit)
      super("The following conversion introduces cycles in the unit system: #{unit}. Remove the conversion or fix the cycle.")
      @unit = unit
    end
  end
end
