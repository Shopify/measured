require "test_helper"

class Measured::ConversionTableTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::Unit.new(:test)
  end

  test "#initialize accepts a list of units and a base unit" do
    Measured::ConversionTable.new([@unit])
  end

  test "#to_h should return a hash for the simple case" do
    expected = {
      "test" => {"test" => BigDecimal("1")}
    }

    assert_equal expected, Measured::ConversionTable.new([@unit]).to_h
  end
end
