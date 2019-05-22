# frozen_string_literal: true
# Extract the subclasses that exist early on because other classes will get added by tests
#   later on in execution and in an unpredictable order.
class ActiveSupport::TestCase
  cattr_accessor :measurable_subclasses
  self.measurable_subclasses = Measured::Measurable.subclasses
end
