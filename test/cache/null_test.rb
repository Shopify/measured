require "test_helper"

class Measured::Cache::NullTest < ActiveSupport::TestCase
  setup do
    @cache = Measured::Cache::Null.new
  end

  test "#exist? false" do
    assert_equal false, @cache.exist?
  end

  test "#read returns nil" do
    assert_nil @cache.read
  end

  test "#write returns nil" do
    assert_nil @cache.write({})
  end
end
