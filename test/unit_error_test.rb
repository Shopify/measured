require "test_helper"

class Measured::UnitErrorTest < ActiveSupport::TestCase
  test "error class exists and is a subclass of StandardError" do
    assert Measured::UnitError.ancestors.include?(StandardError)
  end
end
