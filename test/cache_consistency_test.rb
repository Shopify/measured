require "test_helper"

class Measured::CacheConsistencyTest < ActiveSupport::TestCase
  measurable_subclasses.each do |measurable|
    if measurable.unit_system.cached?
      test "cached measurable #{ measurable } is not out of sync with the definition" do
        skip
      end
    end
  end
end
