# frozen_string_literal: true
require "test_helper"

class Measured::ArithmeticTest < ActiveSupport::TestCase
  setup do
    @two = Magic.new(2, :magic_missile)
    @three = Magic.new(3, :magic_missile)
    @four = Magic.new(4, :magic_missile)
  end

  test 'can check for zero?' do
    assert Magic.new(0, :magic_missile).zero?
    refute Magic.new(1, :magic_missile).zero?
  end

  test 'can check for nonzero?' do
    assert Magic.new(10, :magic_missile), Magic.new(10, :magic_missile).nonzero?
    refute Magic.new(0, :magic_missile).nonzero?
  end

  test 'can check for positive?' do
    assert Magic.new(1, :magic_missile).positive?
    refute Magic.new(-1, :magic_missile).positive?
  end

  test 'can check for negative?' do
    assert Magic.new(-1, :magic_missile).negative?
    refute Magic.new(1, :magic_missile).negative?
  end

  test "#+ should add together same units" do
    assert_equal Magic.new(5, :magic_missile), @two + @three
    assert_equal Magic.new(5, :magic_missile), @three + @two
  end

  test "#+ shouldn't add with a Integer" do
    assert_raises(TypeError) { @two + 3 }
    assert_raises(TypeError) { 2 + @three }
  end

  test "#+ should raise if different unit system" do
    assert_raises TypeError do
      OtherFakeSystem.new(1, :other_fake_base) + @two
    end

    assert_raises TypeError do
      @two + OtherFakeSystem.new(1, :other_fake_base)
    end
  end

  test "#+ should raise if adding something nonsense" do
    assert_raises TypeError do
      @two + "thing"
    end

    assert_raises TypeError do
      "thing" + @two
    end
  end

  test "#- should subtract same units" do
    assert_equal Magic.new(-1, :magic_missile), @two - @three
    assert_equal Magic.new(1, :magic_missile), @three - @two
  end

  test "#- shouldn't subtract with a Integer" do
    assert_raises(TypeError) { @two - 3 }
    assert_raises(TypeError) { 2 - @three }
  end

  test "#- should raise if different unit system" do
    assert_raises TypeError do
      OtherFakeSystem.new(1, :other_fake_base) - @two
    end

    assert_raises TypeError do
      @two - OtherFakeSystem.new(1, :other_fake_base)
    end
  end

  test "#- should raise if subtracting something nonsense" do
    assert_raises TypeError do
      @two - "thing"
    end

    assert_raises NoMethodError do
      "thing" - @two
    end
  end

  test "#-@ returns the negative version" do
    assert_equal Magic.new(-2, :magic_missile), -@two
  end

  test "#scale should multiply the value by a given scalar" do
    assert_equal Magic.new(-2, :magic_missile), @two.scale(-1)
    assert_equal Magic.new(5, :magic_missile), @two.scale(2.5)
  end

  test "arithmetic operations favours unit of left" do
    left = Magic.new(1, :arcane)
    right = Magic.new(1, :magic_missile)
    arcane = Magic.unit_system.unit_for!(:arcane)

    assert_equal arcane, (left + right).unit
    assert_equal arcane, (left - right).unit
  end

  test "#coerce should return other as-is when same class" do
    assert_equal [@two, @three], @three.coerce(@two)
  end

  test "#coerce should raise TypeError when other cannot be coerced" do
    assert_raises(TypeError) { @two.coerce(2) }
    assert_raises(TypeError) { @three.coerce(5.2) }
    assert_raises(TypeError) { @four.coerce(Object.new) }
  end
end
