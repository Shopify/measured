# frozen_string_literal: true
require "test_helper"

class Measured::Cache::JsonTest < Minitest::Test
  setup do
    @cache = Measured::Cache::Json.new("test.json")
    @table_json = { "a" => { "b" => { "numerator" => 2, "denominator" => 3 } } }.to_json
    @table_hash = { "a" => { "b" => Rational(2, 3) } }
  end

  test "#initialize sets the filename and path" do
    assert_equal "test.json", @cache.filename
    assert_match(/.+\/cache\/test\.json$/, @cache.path.to_s)
    refute_match "../", @cache.path.to_s
  end

  test "#exist? returns false if the file does not exist" do
    File.expects(:exist?).with(@cache.path).returns(false)
    refute_predicate @cache, :exist?
  end

  test "#exist? returns true if the file exists" do
    File.expects(:exist?).with(@cache.path).returns(true)
    assert_predicate @cache, :exist?
  end

  test "#read returns nil if the file does not exist" do
    File.expects(:exist?).with(@cache.path).returns(false)
    assert_nil @cache.read
  end

  test "#read loads the file if it exists" do
    File.expects(:exist?).with(@cache.path).returns(true)
    File.expects(:read).with(@cache.path).returns(@table_json)
    assert_equal @table_hash, @cache.read
  end

  test "#write raises not implemented" do
    assert_raises(ArgumentError) do
      @cache.write({})
    end
  end
end
