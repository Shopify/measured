# frozen_string_literal: true
class Thing < ActiveRecord::Base

  measured_length :length, :width

  measured Measured::Length, :height
  measured Measured::Volume, :volume

  measured_weight :total_weight

  measured "Measured::Weight", :extra_weight

  measured_length :length_with_max_on_assignment, {max_on_assignment: 500}
end
