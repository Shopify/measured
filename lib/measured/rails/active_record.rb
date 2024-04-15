# frozen_string_literal: true

module Measured::Rails::ActiveRecord
  extend ActiveSupport::Concern

  module ClassMethods
    def measured(measured_class, *fields)
      options = fields.extract_options!
      options = {}.merge(options)

      measured_class = measured_class.constantize if measured_class.is_a?(String)
      unless measured_class.is_a?(Class) && measured_class.ancestors.include?(Measured::Measurable)
        raise Measured::Rails::Error, "Expecting #{ measured_class } to be a subclass of Measured::Measurable"
      end

      options[:class] = measured_class

      fields.map(&:to_sym).each do |field|
        raise Measured::Rails::Error, "The field #{ field } has already been measured" if measured_fields.key?(field)

        measured_fields[field] = options

        unit_field_name = if options[:unit_field_name]
          measured_fields[field][:unit_field_name] = options[:unit_field_name].to_s
        else
          "#{ field }_unit"
        end

        value_field_name = if options[:value_field_name]
          measured_fields[field][:value_field_name] = options[:value_field_name].to_s
        else
          "#{ field }_value"
        end

        # Reader to retrieve measured object
        define_method(field) do
          value = public_send(value_field_name)
          unit = public_send(unit_field_name)

          return nil unless value && unit

          instance = instance_variable_get("@measured_#{ field }") if instance_variable_defined?("@measured_#{ field }")
          new_instance = begin
            measured_class.new(value, unit)
          rescue Measured::UnitError
            nil
          end

          if instance == new_instance
            instance
          else
            instance_variable_set("@measured_#{ field }", new_instance)
          end
        end

        # Writer to assign measured object
        define_method("#{ field }=") do |incoming|
          if incoming.is_a?(measured_class)
            instance_variable_set("@measured_#{ field }", incoming)
            precision = self.column_for_attribute(value_field_name).precision
            scale = self.column_for_attribute(value_field_name).scale
            rounded_to_scale_value = incoming.value.round(scale)

            max = self.class.measured_fields[field][:max_on_assignment]
            if max && rounded_to_scale_value > max
              rounded_to_scale_value = max
            elsif rounded_to_scale_value.to_i.to_s.length > (precision - scale)
              raise Measured::Rails::Error, "The value #{rounded_to_scale_value} being set for column '#{value_field_name}' has too many significant digits. Please ensure it has no more than #{precision - scale} significant digits."
            end

            public_send("#{ value_field_name }=", rounded_to_scale_value)
            public_send("#{ unit_field_name }=", incoming.unit.name)
          else
            instance_variable_set("@measured_#{ field }", nil)
            public_send("#{ value_field_name}=", nil)
            public_send("#{ unit_field_name }=", nil)
          end
        end

        # Writer to override unit assignment
        redefine_method("#{ unit_field_name }=") do |incoming|
          unit_name = measured_class.unit_system.unit_for(incoming).try!(:name)
          write_attribute(unit_field_name, unit_name || incoming)
        end
      end
    end

    def measured_fields
      @measured_fields ||= {}
    end

  end

  module Length
    extend ActiveSupport::Concern

    module ClassMethods
      def measured_length(*fields)
        measured(Measured::Length, *fields)
      end
    end
  end

  module Volume
    extend ActiveSupport::Concern

    module ClassMethods
      def measured_volume(*fields)
        measured(Measured::Volume, *fields)
      end
    end
  end

  module Weight
    extend ActiveSupport::Concern

    module ClassMethods
      def measured_weight(*fields)
        measured(Measured::Weight, *fields)
      end
    end
  end
end

::ActiveRecord::Base.include(
  Measured::Rails::ActiveRecord,
  Measured::Rails::ActiveRecord::Length,
  Measured::Rails::ActiveRecord::Volume,
  Measured::Rails::ActiveRecord::Weight,
)
