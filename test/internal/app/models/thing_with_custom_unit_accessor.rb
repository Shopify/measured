# frozen_string_literal: true
class ThingWithCustomUnitAccessor < ActiveRecord::Base
  measured_length :length, :width, unit_field_name: :size_unit
  validates :length, measured: true
  validates :width, measured: true

  measured_volume :volume
  validates :volume, measured: true

  measured Measured::Length, :height, unit_field_name: :size_unit
  validates :height, measured: true

  measured_weight :total_weight, unit_field_name: :weight_unit
  validates :total_weight, measured: true

  measured "Measured::Weight", :extra_weight, unit_field_name: :weight_unit
  validates :extra_weight, measured: true
end
