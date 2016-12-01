require "test_helper"

class Measured::ArithmeticTest < ActiveSupport::TestCase
  setup do
    @two = Magic.new(2, :magic_missile)
    @three = Magic.new(3, :magic_missile)
    @four = Magic.new(4, :magic_missile)
  end

  test "#+ should add together same units" do
    assert_equal Magic.new(5, :magic_missile), @two + @three
    assert_equal Magic.new(5, :magic_missile), @three + @two
  end

  test "#+ should add a number to the value" do
    assert_equal Magic.new(5, :magic_missile), @two + 3
    assert_equal Magic.new(5, :magic_missile), 2 + @three
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

  test "#- should subtract a number from the value" do
    assert_equal Magic.new(-1, :magic_missile), @two - 3
    assert_equal Magic.new(-1, :magic_missile), 2 - @three
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

  test "#* should multiply together same units" do
    assert_equal Magic.new(6, :magic_missile), @two * @three
    assert_equal Magic.new(6, :magic_missile), @three * @two
  end

  test "#* should multiply a number to the value" do
    assert_equal Magic.new(6, :magic_missile), @two * 3
    assert_equal Magic.new(6, :magic_missile), 2 * @three
  end

  test "#* should raise if different unit system" do
    assert_raises TypeError do
      OtherFakeSystem.new(1, :other_fake_base) * @two
    end

    assert_raises TypeError do
      @two * OtherFakeSystem.new(1, :other_fake_base)
    end
  end

  test "#* should raise if multiplying something nonsense" do
    assert_raises TypeError do
      @two * "thing"
    end

    assert_raises TypeError do
      "thing" * @two
    end
  end

  test "#/ should divide together same units" do
    assert_equal Magic.new("0.5", :magic_missile), @two / @four
    assert_equal Magic.new(2, :magic_missile), @four / @two
  end

  test "#/ should divide a number to the value" do
    assert_equal Magic.new("0.5", :magic_missile), @two / 4
    assert_equal Magic.new(0.5, :magic_missile), 2 / @four
  end

  test "#/ should raise if different unit system" do
    assert_raises TypeError do
      OtherFakeSystem.new(1, :other_fake_base) / @two
    end

    assert_raises TypeError do
      @two / OtherFakeSystem.new(1, :other_fake_base)
    end
  end

  test "#/ should raise if dividing something nonsense" do
    assert_raises TypeError do
      @two / "thing"
    end

    assert_raises NoMethodError do
      "thing" / @two
    end
  end

  test "#-@ returns the negative version" do
    assert_equal Magic.new(-2, :magic_missile), -@two
  end

  test "#coerce should return other as-is when same class" do
    assert_equal [@two, @three], @three.coerce(@two)
  end

  test "#coerce should return Fixnum as self's class and same unit" do
    expected = Magic.new(2, :magic_missile)
    assert_equal [expected, @three], @three.coerce(2)
  end

  test "#coerce should raise TypeError when other cannot be coerced" do
    assert_raises TypeError do
      @two.coerce(Object.new)
    end
  end
end
