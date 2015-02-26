require "measured/version"
require "active_support"
require "bigdecimal"

module Measured
  class UnitError < StandardError ; end
end

require "measured/arithmetic"
require "measured/unit"
require "measured/conversion"
require "measured/conversion_table"
require "measured/measurable"
