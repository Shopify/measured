# frozen_string_literal: true
require "test_helper"

class Measured::UnitErrorTest < Minitest::Test
  test "error class exists and is a subclass of StandardError" do
    assert Measured::UnitError.ancestors.include?(StandardError)
  end
end
