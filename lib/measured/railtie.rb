# frozen_string_literal: true

module Measured
  class Rails < ::Rails::Railtie
    class Error < StandardError ; end

    ActiveSupport.on_load(:active_record) do
      require "measured/rails/active_record"
      require "measured/rails/validations"
    end
  end
end
