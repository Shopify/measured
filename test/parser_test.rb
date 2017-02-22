require "test_helper"

class Measured::ParserTest < ActiveSupport::TestCase
  test "#parse raises on nil input" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string(nil)
    end
    assert_equal "Cannot parse blank measurement", exception.message
  end

  test "#parse raises on blank string input" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string("")
    end
    assert_equal "Cannot parse blank measurement", exception.message
  end

  test "#parse raises on a single incorrect string" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string("word")
    end
    assert_equal "Cannot parse measurement from 'word'", exception.message
  end

  test "#parse raises on a single incorrect number" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string("1234")
    end
    assert_equal "Cannot parse measurement from '1234'", exception.message
  end

  test "#parse raises on a multiple incorrect numbers" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string("12.34 9999")
    end
    assert_equal "Cannot parse measurement from '12.34 9999'", exception.message
  end

  test "#parse takes input with a space between" do
    assert_equal [Rational(2, 1), "test"], Measured::Parser.parse_string("4/2 test")
  end

  test "#parse takes input without a space" do
    assert_equal [Rational(7, 2), "test"], Measured::Parser.parse_string("3.5test")
  end

  test "#parse takes input with a number in the unit" do
    assert_equal [Rational(1, 1), "test3test"], Measured::Parser.parse_string("1 test3test")
  end

  test "#parse raises on a number first unit digit" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string("1 1test")
    end
    assert_equal "Cannot parse measurement from '1 1test'", exception.message
  end

  test "#parse takes float with a space" do
    assert_equal [Rational(5, 4), "test"], Measured::Parser.parse_string("1.25 test")
  end

  test "#parse takes float without a space" do
    assert_equal [Rational(251, 5), "test"], Measured::Parser.parse_string("50.2test")
  end

  test "#parse truncates any space before and after" do
    assert_equal [Rational(111111, 100), "test"], Measured::Parser.parse_string("   1111.11     test    ")
  end

  test "#parse raises with multiple periods in fractional numbers" do
    exception = assert_raises(Measured::UnitError) do
      Measured::Parser.parse_string("12.34.56 test")
    end
    assert_equal "Cannot parse measurement from '12.34.56 test'", exception.message
  end

  test "#parse takes multiple words for the unit" do
    assert_equal [Rational(2345, 1), "a b cde"], Measured::Parser.parse_string(" 2345 a b cde  ")
  end

  test "#parse parses negative numbers" do
    assert_equal [Rational(-13, 4), "test"], Measured::Parser.parse_string("-3.25 test")
  end

  test "#parse parses rational numbers" do
    assert_equal [Rational(3, 2), "test"], Measured::Parser.parse_string("3/2test")
  end
end
