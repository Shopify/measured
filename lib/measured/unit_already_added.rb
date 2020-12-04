# frozen_string_literal: true
module Measured
  class UnitAlreadyAdded < UnitError
    attr_reader :unit_name

    def initialize(unit_name)
      super("Unit #{unit_name} has already been added.")
      @unit_name = unit_name
    end
  end
end
