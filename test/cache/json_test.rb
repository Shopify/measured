require "test_helper"

class Measured::Cache::JsonTest < ActiveSupport::TestCase
  setup do
    @cache = Measured::Cache::Json.new("test.json")
    @table_json = { "a" => { "b" => { "numerator" => 2, "denominator" => 3 } } }.to_json
    @table_hash = { "a" => { "b" => Rational(2, 3) } }
  end

  test "#initialize sets the filename and path" do
    assert_equal "test.json", @cache.filename
    assert_match /.+\/cache\/test\.json$/, @cache.path.to_s
    refute_match "../", @cache.path.to_s
  end

  test "#exist? returns false if the file does not exist" do
    refute_predicate @cache, :exist?
  end

  test "#exist? returns true if the file exists" do
    MemFs.activate do
      MemFs.touch(@cache.path)
      assert_predicate @cache, :exist?
    end
  end

  test "#read returns nil if the file does not exist" do
    MemFs.activate do
      assert_nil @cache.read
    end
  end

  test "#read loads the file if it exists" do
    MemFs.activate do
      MemFs.touch(@cache.path)
      File.open(@cache.path, "w") do |f|
        f.write(@table_json)
      end
      assert_equal @table_hash, @cache.read
    end
  end

  test "#write raises not implemented" do
    assert_raises(ArgumentError) do
      @cache.write({})
    end
  end
end
