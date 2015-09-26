require "measured/version"
require "active_support/all"
require "bigdecimal"

module Measured
  class UnitError < StandardError ; end

  class << self
    def method_missing(method, *args)
      class_name = "Measured::#{ method }"

      if Measured::Measurable.subclasses.map(&:to_s).include?(class_name)
        klass = class_name.constantize

        Measured.define_singleton_method(method) do |value, unit|
          klass.new(value, unit)
        end

        klass.new(*args)
      else
        super
      end
    end
  end
end

require "measured/arithmetic"
require "measured/unit"
require "measured/conversion"
require "measured/conversion_table"
require "measured/measurable"
require "measured/case_sensitive_measurable"
