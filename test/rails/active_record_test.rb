# frozen_string_literal: true
require "test_helper"

class Measured::Rails::ActiveRecordTest < ActiveSupport::TestCase
  setup do
    reset_db
  end

  test ".measured raises if called with something that isn't a Measured::Measurable" do
    assert_raises Measured::Rails::Error do
      Thing.measured(Object, :field)
    end
  end

  test ".measured raises if called with something that isn't a class" do
    assert_raises Measured::Rails::Error do
      Thing.measured(:not_correct, :field)
    end
  end

  test ".measured raises if you attempt to define a field twice" do
    assert_raises Measured::Rails::Error do
      Thing.measured Measured::Length, :height
    end
  end

  test ".measured defines a reader for the field" do
    assert_equal length, thing.length
  end

  test ".measured defines a writer for the field that returns" do
    assert_equal new_length, thing.length=(new_length)
  end

  test ".measured_fields returns the configuration for all measured fields on the class" do
    expected = {
      length: { class: Measured::Length },
      width: { class: Measured::Length },
      height: { class: Measured::Length },
      volume: { class: Measured::Volume },
      total_weight: { class: Measured::Weight },
      extra_weight: { class: Measured::Weight },
      length_with_max_on_assignment: { max_on_assignment: 500, class: Measured::Length }
    }

    assert_equal expected, Thing.measured_fields
  end

  test "reader returns the exact same object if the values are equivalent" do
    thing.length = new_length
    assert_equal new_length.object_id, thing.length.object_id
  end

  test "reader creates an instance from the _value and _unit columns" do
    thing = Thing.new
    thing.width_value = 23
    thing.width_unit = "ft"
    assert_equal Measured::Length.new(23, :ft), thing.width
  end

  test "reader creates creating an instance from columns caches the same object" do
    thing = Thing.new
    thing.width_value = 23
    thing.width_unit = "ft"
    assert_equal thing.width.object_id, thing.width.object_id
  end

  test "reader deals with only the _value column set" do
    thing = Thing.new
    thing.width_value = 23
    assert_nil thing.width
  end

  test "reader deals with only the _unit column set" do
    thing = Thing.new
    thing.width_unit = "cm"
    assert_nil thing.width
  end

  test "reader deals with nil-ing out the _value column" do
    thing.width_value = nil
    assert_nil thing.width
  end

  test "reader deals with nil-ing out the _unit column" do
    thing.width_unit = nil
    assert_nil thing.width
  end

  test "writer sets the value to nil if it is an incompatible object" do
    thing.length = Object.new
    assert_nil thing.length
  end

  test "writer assigning nil blanks out the unit and value columns" do
    thing.width = nil
    assert_nil thing.width
    assert_nil thing.width_unit
    assert_nil thing.width_value
  end

  test "assigning an invalid _unit sets the column but the measurable object is nil" do
    thing.width_unit = "invalid"
    assert_nil thing.width
    assert_equal "invalid", thing.width_unit
  end

  test "assigning an invalid _unit sets the column but the measurable object is nil and there is validation on the column" do
    validated_thing.length_unit = "invalid"
    validated_thing.valid?
    assert_nil validated_thing.length
    assert_equal "invalid", validated_thing.length_unit
  end

  test "assigning a valid _unit sets it" do
    thing.width_unit = :mm
    assert_equal thing.width, Measured::Length.new(6, "mm")
    assert_equal "mm", thing.width_unit
  end

  test "assigning a non-base unit to _unit converts it to its base unit" do
    thing.width_unit = "millimetre"
    assert_equal thing.width, Measured::Length.new(6, "mm")
    assert_equal "mm", thing.width_unit
  end

  test "building a new object from attributes builds a measured object" do
    thing = Thing.new(length_value: "30", length_unit: "m")
    assert_equal Measured::Length.new(30, :m), thing.length
  end

  test "building a new object with a measured object assigns the properties" do
    thing = Thing.new(length: new_length)
    assert_equal new_length, thing.length
    assert_equal 20, thing.length_value
    assert_equal "in", thing.length_unit
  end

  test "assigning attributes updates the measured object" do
    thing.attributes = {length_value: "30", length_unit: "m"}
    assert_equal Measured::Length.new(30, :m), thing.length
  end

  test "assigning partial attributes updates the measured object" do
    thing.attributes = {length_value: "30"}
    assert_equal Measured::Length.new(30, :cm), thing.length
  end

  test "assigning the _unit leaves the _value unchanged" do
    thing.total_weight_unit = :lb
    assert_equal thing.total_weight, Measured::Weight.new(200, "lb")
  end

  test "assigning the _value leaves the _unit unchanged" do
    thing.total_weight_value = "10"
    assert_equal thing.total_weight, Measured::Weight.new(10, :g)
  end

  test "assigning the _unit to an invalid unit does not raise" do
    thing.total_weight_value = 123
    thing.total_weight_unit = :invalid
    assert_nil thing.total_weight
  end

  test "save persists the attributes and retrieves an object" do
    thing = Thing.new length: Measured::Length.new(3, :m)
    assert thing.save
    assert_equal 3, thing.length_value
    assert_equal "m", thing.length_unit
    thing.reload
    assert_equal 3, thing.length_value
    assert_equal "m", thing.length_unit
  end

  test "save pulls attributes from assigned object" do
    thing = Thing.new total_weight_value: "100", total_weight_unit: :lb
    assert thing.save
    thing.reload
    assert_equal 100, thing.total_weight_value
    assert_equal "lb", thing.total_weight_unit
    assert_equal Measured::Weight.new(100, :lb), thing.total_weight
  end

  test "save succeeds if you assign an invalid unit and there is no validation" do
    thing = Thing.new total_weight_value: "100", total_weight_unit: :invalid
    assert thing.save
    thing.reload
    assert_nil thing.total_weight
    assert_equal 100, thing.total_weight_value
  end

  test "save fails if you assign an invalid unit and there is validation" do
    thing = validated_thing
    thing.length_unit = "invalid"
    refute thing.save
    assert_nil thing.length
  end

  test "update sets one then the other" do
    thing = Thing.create!
    assert thing.update(width_value: 11.1)
    assert_nil thing.width
    assert thing.update(width_unit: "cm")
    assert_equal Measured::Length.new(11.1, :cm), thing.width
  end

  test "update sets only the _value column" do
    thing = Thing.create!
    assert thing.update(width_value: "314")
    assert_equal 314, thing.width_value
    thing.reload
    assert_equal 314, thing.width_value
    assert_nil thing.width
  end

  test "update sets only the _unit column" do
    thing = Thing.create!
    assert thing.update(width_unit: :cm)
    assert_equal "cm", thing.width_unit
    thing.reload
    assert_equal "cm", thing.width_unit
    assert_nil thing.width
  end

  test "update sets only the _unit column and converts it" do
    thing = Thing.create!
    assert thing.update(width_unit: "inch")
    assert_equal "in", thing.width_unit
    thing.reload
    assert_equal "in", thing.width_unit
  end

  test "update sets the _unit column to something invalid" do
    thing = Thing.create!
    assert thing.update(width_unit: :invalid)
    assert_equal "invalid", thing.width_unit
    thing.reload
    assert_equal "invalid", thing.width_unit
    assert_nil thing.width
  end

  test "update does not set the _unit column to something invalid if there is validation" do
    thing = validated_thing
    thing.save!
    refute thing.update(length_unit: :invalid)
  end

  test "update sets one column then the other" do
    thing = Thing.create!
    assert thing.update(width_unit: "inch")
    assert_nil thing.width
    assert thing.update(width_value: "314")
    assert_equal Measured::Length.new(314, :in), thing.width
  end

  test "update sets both columns" do
    thing = Thing.create!
    assert thing.update(width_unit: :cm, width_value: 2)
    assert_equal Measured::Length.new(2, :cm), thing.width
    thing.reload
    assert_equal Measured::Length.new(2, :cm), thing.width
  end

  test "update modifies the _value column" do
    assert thing.update(height_value: 2)
    assert_equal Measured::Length.new(2, :m), thing.height
    thing.reload
    assert_equal Measured::Length.new(2, :m), thing.height
  end

  test "update modifies only the _unit column" do
    assert thing.update(height_unit: "foot")
    assert_equal Measured::Length.new(1, :ft), thing.height
    thing.reload
    assert_equal Measured::Length.new(1, :ft), thing.height
  end

  test "update modifies the _unit column to be something invalid" do
    assert thing.update(height_unit: :invalid)
    assert_nil thing.height
    assert_equal "invalid", thing.height_unit
    thing.reload
    assert_nil thing.height
    assert_equal "invalid", thing.height_unit
  end

  test "update modifies both columns" do
    assert thing.update(height_unit: "mm", height_value: 1.23)
    assert_equal Measured::Length.new(1.23, :mm), thing.height
    thing.reload
    assert_equal Measured::Length.new(1.23, :mm), thing.height
  end

  test "assigning the _value with a BigDecimal rounds to the column's rounding scale" do
    thing.height = Measured::Length.new(BigDecimal('23.4567891'), :mm)
    assert_equal thing.height_value, BigDecimal('23.46')
  end

  test "assigning the _value with a float uses all the rounding scale permissible" do
    thing.height = Measured::Length.new(4.45678912, :mm)
    assert_equal thing.height_value, BigDecimal('4.46')
  end

  test "assigning a number with more significant digits than permitted by the column precision does not raise exception when it can be rounded to have lesser significant digits per column's scale" do
    assert_nothing_raised do
      thing.height = Measured::Length.new(4.45678912123123123, :mm)
      assert_equal thing.height_value, BigDecimal('4.46')
    end
  end

  test "assigning a number with more significant digits than permitted by the column precision raises exception" do
    assert_raises Measured::Rails::Error, "The value 44567891212312312.3 being set for column: 'height' has too many significant digits. Please ensure it has no more than 10 significant digits." do
      thing.height = Measured::Length.new(44567891212312312.3, :mm)
    end
  end

  test "assigning a large number but with a small amount of significant digits than permitted by the column precision raises exception" do
    assert_raises Measured::Rails::Error, "The value 2000000000000000.0 being set for column: 'height' has too many significant digits. Please ensure it has no more than 10 significant digits." do
      thing.height = Measured::Length.new(2_000_000_000_000_000, :mm)
    end
  end

  test "assigning a large number that's just smaller, equal to, and over the size of the column precision raises exception" do
    assert_nothing_raised do
      thing.height = Measured::Length.new(99999999.99, :mm)
    end

    assert_raises Measured::Rails::Error, "The value 100000000.0 being set for column: 'height' has too many significant digits. Please ensure it has no more than 10 significant digits." do
      thing.height = Measured::Length.new(100000000, :mm)
    end

    assert_raises Measured::Rails::Error, "The value 100000000.01 being set for column: 'height' has too many significant digits. Please ensure it has no more than 10 significant digits." do
      thing.height = Measured::Length.new(100000000.01, :mm)
    end
  end

  test "assigning a large number to a field that specifies max_on_assignment" do
    thing = Thing.create!(length_with_max_on_assignment: Measured::Length.new(10000000000000000, :mm))
    assert_equal Measured::Length.new(500, :mm), thing.length_with_max_on_assignment
  end

  test "assigning a small number to a field that specifies max_on_assignment" do
     thing = Thing.create!(length_with_max_on_assignment: Measured::Length.new(1, :mm))
     assert_equal Measured::Length.new(1, :mm), thing.length_with_max_on_assignment
  end

  test "using a similar unit accessor for multiple size fields" do
    assert_equal Measured::Length.new(1, :m), custom_unit_thing.length
    assert_equal Measured::Length.new(2, :m), custom_unit_thing.width
    assert_equal Measured::Length.new(3, :m), custom_unit_thing.height
    assert_equal Measured::Volume.new(9, :l), custom_unit_thing.volume
    assert_equal Measured::Weight.new(10, :g), custom_unit_thing.total_weight
    assert_equal Measured::Weight.new(12, :g), custom_unit_thing.extra_weight
  end

  test "changing unit value when shared affects all fields" do
    custom_unit_thing.length = Measured::Length.new(15, :in)
    custom_unit_thing.total_weight = Measured::Weight.new(42, :kg)

    assert_equal custom_unit_thing.length, Measured::Length.new(15, :in)
    assert_equal custom_unit_thing.width, Measured::Length.new(2, :in)
    assert_equal custom_unit_thing.height, Measured::Length.new(3, :in)
    assert_equal custom_unit_thing.total_weight, Measured::Weight.new(42, :kg)
    assert_equal custom_unit_thing.extra_weight, Measured::Weight.new(12, :kg)
  end

  test "using custom value fields works correctly" do
    assert_equal custom_value_thing.length, Measured::Length.new(4, :m)
    assert_equal custom_value_thing.width, Measured::Length.new(5, :m)
    assert_equal custom_value_thing.height, Measured::Length.new(6, :m)
    assert_equal custom_value_thing.volume, Measured::Volume.new(13, :l)
    assert_equal custom_value_thing.total_weight, Measured::Weight.new(14, :g)
    assert_equal custom_value_thing.extra_weight, Measured::Weight.new(15, :g)
  end

  private

  def length
    @length ||= Measured::Length.new(10, :cm)
  end

  def new_length
    @new_length ||= Measured::Length.new(20, :in)
  end

  def thing
    @thing ||= Thing.create!(
      length: length,
      width: Measured::Length.new(6, :in),
      volume: Measured::Volume.new(6, :l),
      height: Measured::Length.new(1, :m),
      total_weight: Measured::Weight.new(200, :g),
      extra_weight: Measured::Weight.new(16, :oz)
    )
  end

  def validated_thing
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
      volume: Measured::Volume.new(9, :l),
      total_weight: Measured::Weight.new(10, :g),
      extra_weight: Measured::Weight.new(12, :g),
    )
  end

  def custom_value_thing
    @custom_value_thing ||= ThingWithCustomValueAccessor.new(
      length: Measured::Length.new(4, :m),
      width: Measured::Length.new(5, :m),
      height: Measured::Length.new(6, :m),
      volume: Measured::Volume.new(13, :l),
      total_weight: Measured::Weight.new(14, :g),
      extra_weight: Measured::Weight.new(15, :g),
    )
  end
end
