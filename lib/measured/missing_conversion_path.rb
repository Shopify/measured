module Measured
  class MissingConversionPath < UnitError
    attr_reader :from, :to

    def initialize(from, to)
      super("Cannot find conversion path from #{from} to #{to}.")
      @from = from
      @to = to
    end
  end
end
