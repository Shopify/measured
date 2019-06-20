# frozen_string_literal: true
# Extract the subclasses that exist early on because other classes will get added by tests
#   later on in execution and in an unpredictable order.
require 'active_support/core_ext/class/subclasses'

module Measured
  MeasurableSubclasses = Measured::Measurable.subclasses
end
