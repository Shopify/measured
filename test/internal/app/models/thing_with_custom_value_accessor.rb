# frozen_string_literal: true
class ThingWithCustomValueAccessor < ActiveRecord::Base
  measured_length :length, value_field_name: :custom_length
  validates :length, measured: true
  measured_length :width, value_field_name: :custom_width
  validates :width, measured: true

  measured_volume :volume, value_field_name: :custom_volume
  validates :volume, measured: true

  measured_length :height, value_field_name: :custom_height
  validates :height, measured: true

  measured_weight :total_weight, value_field_name: :custom_weight
  validates :total_weight, measured: true

  measured_weight :extra_weight, value_field_name: :custom_extra_weight
  validates :extra_weight, measured: true
end
