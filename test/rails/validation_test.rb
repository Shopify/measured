# frozen_string_literal: true
require "test_helper"

class Measured::Rails::ValidationTest < ActiveSupport::TestCase
  setup do
    reset_db
  end

  test "validation mock is valid" do
    assert thing.valid?
  end

  test "validation measurable: validation leaves a model valid and deals with blank unit" do
    assert ValidatedThing.new(length_presence: Measured::Length.new(4, :in)).valid?
  end

  test "validation fails when unit is nil" do
    thing.length_unit = ''
    refute thing.valid?
    assert_equal({ length: ["is not a valid unit"] }, thing.errors.to_hash)
  end

  test "validation fails on model with custom unit with nil value" do
    custom_unit_thing.size_unit = ''
    refute custom_unit_thing.valid?
    assert_equal(
      {
        length: ["is not a valid unit"],
        width:  ["is not a valid unit"],
        height: ["is not a valid unit"],
      },
      custom_unit_thing.errors.to_hash
    )
  end

  test "validation true works by default" do
    thing.length_unit = "junk"
    refute thing.valid?
    assert_equal ["Length is not a valid unit"], thing.errors.full_messages
  end

  test "validation can override the message with a static string" do
    thing.length_message_unit = "junk"
    refute thing.valid?
    assert_equal ["Length message has a custom failure message"], thing.errors.full_messages
  end

  test "validation can override the message with a block" do
    thing.length_message_from_block_unit = "junk"
    refute thing.valid?
    assert_equal ["Length message from block junk is not a valid unit"], thing.errors.full_messages
  end

  test "validation may be any valid unit" do
    length_units.each do |unit|
      thing.length_unit = unit
      assert thing.valid?
      thing.length_unit = unit.to_s
      assert thing.valid?
      thing.length = Measured::Length.new(123, unit)
      assert thing.valid?
    end
  end

  test "validation accepts a list of units in any format as an option and only allows them to be valid" do
    thing.length_units_unit = :m
    assert thing.valid?
    thing.length_units_unit = :cm
    assert thing.valid?
    thing.length_units_unit = "cm"
    assert thing.valid?
    thing.length_units_unit = "meter"
    assert thing.valid?
    thing.length_units = Measured::Length.new(3, :cm)
    assert thing.valid?
    thing.length_units_unit = :mm
    refute thing.valid?
    thing.length_units = Measured::Length.new(3, :ft)
    refute thing.valid?
  end

  test "validation lets the unit be singular" do
    thing.length_units_singular_unit = :ft
    assert thing.valid?
    thing.length_units_singular_unit = "feet"
    assert thing.valid?
    thing.length_units_singular_unit = :mm
    refute thing.valid?
    thing.length_units_singular_unit = "meter"
    refute thing.valid?
  end

  test "validation for unit reasons uses the default message" do
    thing.length_units_unit = :mm
    refute thing.valid?
    assert_equal ["Length units is not a valid unit"], thing.errors.full_messages
  end

  test "validation for unit reasons also uses the custom message" do
    thing.length_units_singular_unit = :mm
    refute thing.valid?
    assert_equal ["Length units singular custom message too"], thing.errors.full_messages
  end

  test "validation for unit reasons adds one message if unit is not supported by default and is not custom supported" do
    thing.length_units_singular_unit = :t
    refute thing.valid?

    assert_equal ["Length units singular custom message too"], thing.errors.full_messages
  end

  test "validation presence works on measured columns" do
    thing.length_presence = nil
    refute thing.valid?
    assert_equal ["Length presence can't be blank"], thing.errors.full_messages
    thing.length_presence_unit = "m"
    refute thing.valid?
    thing.length_presence_value = "3"
    assert thing.valid?
  end

  test "validation fails if only only the value is set" do
    thing.length_unit = nil
    refute thing.valid?
  end

  test "validation checks that numericality comparisons are against a Measurable subclass" do
    thing.length_invalid_comparison = Measured::Length.new(30, :in)
    assert_raises ArgumentError, ":not_a_measured_subclass must be a Measurable object" do
      thing.valid?
    end
  end

  test "validation for numericality uses a default invalid message" do
    thing.length_numericality_inclusive = Measured::Length.new(30, :in)
    refute thing.valid?
    assert_equal ["Length numericality inclusive 30 in must be <= 20 in"], thing.errors.full_messages

    thing.length_numericality_inclusive = Measured::Length.new(1, :mm)
    refute thing.valid?
    assert_equal ["Length numericality inclusive 1 mm must be >= 10 in"], thing.errors.full_messages
  end

  test "validation for numericality uses the override message" do
    thing.length_numericality_exclusive = Measured::Length.new(2, :m)
    refute thing.valid?
    assert_equal ["Length numericality exclusive is super not ok"], thing.errors.full_messages

    thing.length_numericality_exclusive = Measured::Length.new(6000, :mm)
    refute thing.valid?
    assert_equal ["Length numericality exclusive is super not ok"], thing.errors.full_messages
  end

  test "validation for numericality checks :greater_than and :less_than and can use symbols as method names to look up values" do
    thing.length_numericality_exclusive = Measured::Length.new(4, :m)
    assert thing.valid?

    thing.length_numericality_exclusive = Measured::Length.new(1, :m)
    refute thing.valid?
  end

  test "validation for numericality checks :greater_than_or_equal_to and :less_than_or_equal_to" do
    thing.length_numericality_inclusive = Measured::Length.new(10, :in)
    assert thing.valid?

    thing.length_numericality_exclusive = Measured::Length.new(3, :m)
    refute thing.valid?
  end

  test "validation for numericality checks :equal_to and can use procs to look up values" do
    thing.length_numericality_equality = Measured::Length.new(100, :cm)
    assert thing.valid?

    thing.length_numericality_equality = Measured::Length.new(1, :m)
    assert thing.valid?

    thing.length_numericality_equality = Measured::Length.new("99.9", :cm)
    refute thing.valid?

    thing.length_numericality_equality = Measured::Length.new(101, :cm)
    refute thing.valid?
  end

  test "validation for numericality handles a nil unit but a valid value" do
    thing.length_numericality_exclusive_unit = nil
    thing.length_numericality_exclusive_value = 1
    refute thing.valid?
  end

  test "allow a nil value but a valid unit" do
    thing.length_numericality_exclusive_unit = :cm
    thing.length_numericality_exclusive_value = nil
    assert thing.valid?
  end

  test "validations work as expected given a measured field with custom validators" do
    assert custom_unit_thing.valid?

    assert custom_unit_thing.size_unit = 'invalid'

    refute custom_unit_thing.valid?

    assert_equal(custom_unit_thing.errors[:length], ["is not a valid unit"])
    assert_equal(custom_unit_thing.errors[:height], ["is not a valid unit"])
    assert_equal(custom_unit_thing.errors[:width], ["is not a valid unit"])
  end

  test "validations work as expected on measured field with custom value accessor" do
    assert custom_value_thing.valid?
  end

  private

  def thing
    @thing ||= ValidatedThing.new(
      length: Measured::Length.new(1, :m),
      length_true: Measured::Length.new(2, :cm),
      length_message: Measured::Length.new(3, :mm),
      length_message_from_block: Measured::Length.new(7, :mm),
      length_units: Measured::Length.new(4, :m),
      length_units_singular: Measured::Length.new(5, :ft),
      length_presence: Measured::Length.new(6, :m),
      length_numericality_inclusive: Measured::Length.new(15, :in),
      length_numericality_exclusive: Measured::Length.new(4, :m),
      length_numericality_equality: Measured::Length.new(100, :cm),
    )
  end

  def custom_unit_thing
    @custom_unit_thing ||= ThingWithCustomUnitAccessor.new(
      length: Measured::Length.new(1, :m),
      width: Measured::Length.new(2, :m),
      height: Measured::Length.new(3, :m),
      total_weight: Measured::Weight.new(10, :g),
      extra_weight: Measured::Weight.new(12, :g),
    )
  end

  def custom_value_thing
    @custom_value_thing = ThingWithCustomValueAccessor.new(
      length: Measured::Length.new(1, :m),
      width: Measured::Length.new(2, :m),
      height: Measured::Length.new(3, :m),
      total_weight: Measured::Weight.new(10, :g),
      extra_weight: Measured::Weight.new(12, :g),
    )
  end

  def length_units
    @length_units ||= [:m, :meter, :cm, :mm, :millimeter, :in, :ft, :feet, :yd]
  end
end
