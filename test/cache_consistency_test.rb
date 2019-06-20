# frozen_string_literal: true
require "test_helper"

# In general we do not want to expose the inner workings of the caching and unit systems as part of the API.
# But we do want to be able to test that there is no conflict between what's in the cache file and what is defined
# in the unit systems. So we compromise by reaching into implementation to force compare them.
module Measured
  class CacheConsistencyTest < Minitest::Test
    MeasurableSubclasses.select { |m| m.unit_system.cached? }.each do |measurable|
      test "cached measurable #{ measurable } is not out of sync with the definition" do
        builder = measurable.unit_system.instance_variable_get("@conversion_table_builder")
        cache = builder.instance_variable_get("@cache")

        expected = builder.send(:generate_table)
        actual = cache.read

        assert expected == actual, "The contents of the file cache for `#{ measurable }` does not match what the unit system generated.\nTry running `rake cache:write` to update the caches."
      end
    end
  end
end
