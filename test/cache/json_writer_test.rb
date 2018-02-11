require "test_helper"

class Measured::Cache::JsonWriterTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  test "#write writes the file" do
    class Measured::Cache::Json
      prepend Measured::Cache::JsonWriter
    end

    @cache = Measured::Cache::Json.new("test.json")
    @table_json = { "a" => { "b" => { "numerator" => 2, "denominator" => 3 } } }.to_json
    @table_hash = { "a" => { "b" => Rational(2, 3) } }

    f = stub
    f.expects(:write).with("// Do not modify this file directly. Regenerate it with 'rake cache:write'.\n")
    f.expects(:write).with(@table_json)

    File.expects(:open).with(@cache.path, "w").returns(123).yields(f)
    assert_equal 123, @cache.write(@table_hash)
  end
end
