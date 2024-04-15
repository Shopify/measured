# frozen_string_literal: true
class ValidatedThing < ActiveRecord::Base
  measured_length :length
  validates :length, measured: true

  measured_length :length_true
  validates :length_true, measured: true

  measured_length :length_message
  validates :length_message, measured: {message: "has a custom failure message"}

  measured_length :length_message_from_block
  validates :length_message_from_block, measured: { message: Proc.new { |record| "#{record.length_message_from_block_unit} is not a valid unit" } }

  measured_length :length_units
  validates :length_units, measured: {units: [:meter, "cm"]}

  measured_length :length_units_singular
  validates :length_units_singular, measured: {units: :ft, message: "custom message too"}

  measured_length :length_presence
  validates :length_presence, measured: true, presence: true

  measured_length :length_numericality_inclusive
  validates :length_numericality_inclusive, measured: {greater_than_or_equal_to: :low_bound, less_than_or_equal_to: :high_bound }

  measured_length :length_numericality_exclusive
  validates :length_numericality_exclusive, measured: {greater_than: Measured::Length.new(3, :m), less_than: Measured::Length.new(500, :cm), message: "is super not ok"}

  measured_length :length_numericality_equality
  validates :length_numericality_equality, measured: {equal_to: Proc.new { Measured::Length.new(100, :cm) }, message: "must be exactly 100cm"}

  measured_length :length_invalid_comparison
  validates :length_invalid_comparison, measured: {equal_to: "not_a_measured_subclass"}

  private

  def low_bound
    Measured::Length.new(10, :in)
  end

  def high_bound
    Measured::Length.new(20, :in)
  end
end
