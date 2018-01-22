require "test_helper"

class Measured::CacheConsistencyTest < ActiveSupport::TestCase
  test "any cache files match what would be generated without the cache" do
    skip

    Measured::Measurable.subclasses.each do |measurable|
      if measurable.unit_system.cached?
        # TODO
      end
    end
  end
end
