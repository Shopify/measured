require "test_helper"

class Measured::ConversionTableTest < ActiveSupport::TestCase
  setup do
    @unit = Measured::Unit.new(:test)
  end

  test "#build should return a hash for the simple case" do
    expected = {
      "test" => {"test" => BigDecimal("1")}
    }

    assert_equal expected, Measured::ConversionTable.build([@unit])
  end
end
