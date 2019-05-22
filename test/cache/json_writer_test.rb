# frozen_string_literal: true
require "test_helper"

class Measured::Cache::JsonWriterTest < ActiveSupport::TestCase
  class JsonTestWithWriter < Measured::Cache::Json
    prepend Measured::Cache::JsonWriter
  end

  setup do
    @cache = JsonTestWithWriter.new("test.json")
    @table_json = JSON.pretty_generate({ "a" => { "b" => { "numerator" => 2, "denominator" => 3 } } })
    @table_hash = { "a" => { "b" => Rational(2, 3) } }
  end

  test "#write writes the file" do
    f = stub
    f.expects(:write).with("// Do not modify this file directly. Regenerate it with 'rake cache:write'.\n")
    f.expects(:write).with(@table_json)

    File.expects(:open).with(@cache.path, "w").returns(123).yields(f)
    assert_equal 123, @cache.write(@table_hash)
  end
end
