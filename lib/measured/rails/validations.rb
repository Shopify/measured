# frozen_string_literal: true

require "active_model/validations"

class MeasuredValidator < ActiveModel::EachValidator
  CHECKS = {
    greater_than: :>,
    greater_than_or_equal_to: :>=,
    equal_to: :==,
    less_than: :<,
    less_than_or_equal_to: :<=,
  }.freeze

  def validate_each(record, attribute, measurable)
    measured_config = record.class.measured_fields[attribute]
    unit_field_name = measured_config[:unit_field_name] || "#{ attribute }_unit"
    value_field_name = measured_config[:value_field_name] || "#{ attribute }_value"

    measured_class = measured_config[:class]

    measurable_unit_name = record.public_send(unit_field_name)
    measurable_value = record.public_send(value_field_name)

    return unless measurable_unit_name.present? || measurable_value.present?

    measurable_unit = measured_class.unit_system.unit_for(measurable_unit_name)
    record.errors.add(attribute, :invalid, message: message(record, "is not a valid unit")) unless measurable_unit

    if options[:units] && measurable_unit.present?
      valid_units = Array(options[:units]).map { |unit| measured_class.unit_system.unit_for(unit) }
      record.errors.add(attribute, :invalid, message: message(record, "is not a valid unit")) unless valid_units.include?(measurable_unit)
    end

    if measurable_unit && measurable_value.present?
      options.slice(*CHECKS.keys).each do |option, value|
        comparable_value = value_for(value, record)
        comparable_value = measured_class.new(comparable_value, measurable_unit) unless comparable_value.is_a?(Measured::Measurable)
        unless measurable.public_send(CHECKS[option], comparable_value)
          record.errors.add(attribute, option, message: message(record, "#{measurable.to_s} must be #{CHECKS[option]} #{comparable_value}"))
        end
      end
    end
  end

  private

  def message(record, default_message)
    if options[:message].respond_to?(:call)
      options[:message].call(record)
    else
      options[:message] || default_message
    end
  end

  def value_for(key, record)
    value = case key
    when Proc
      key.call(record)
    when Symbol
      record.send(key)
    else
      key
    end

    raise ArgumentError, ":#{ value } must be a number or a Measurable object" unless (value.is_a?(Numeric) || value.is_a?(Measured::Measurable))
    value
  end
end
