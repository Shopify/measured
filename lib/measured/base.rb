require "measured/version"
require "active_support/all"
require "bigdecimal"

module Measured
  class UnitError < StandardError ; end

  class << self
    def build(**kwargs, &block)
      builder = UnitSystemBuilder.new(**kwargs)
      builder.instance_eval(&block)

      Class.new(Measurable) do
        class << self
          attr_reader :unit_system
        end

        @unit_system = builder.build
      end
    end

    def method_missing(method, *args)
      class_name = "Measured::#{ method }"

      if Measurable.subclasses.map(&:to_s).include?(class_name)
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
require "measured/base_unit"
require "measured/unit_system"
require "measured/case_insensitive_unit"
require "measured/case_insensitive_unit_system"
require "measured/unit_system_builder"
require "measured/conversion_table"
require "measured/measurable"
