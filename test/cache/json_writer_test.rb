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

    # MemFs.activate do
    #   MemFs.touch(@cache.path)
    #   result = @cache.write(@table_hash)
    #   refute_nil result
    #   assert result > 0
    #   contents = File.open(@cache.path, "r") { |f| f.read }
    #   assert_match @table_json, contents
    #   assert_match "Do not modify this file", contents
    # end
  end
end
