require "measured/version"
require "active_support/all"
require "bigdecimal"

module Measured
  class UnitError < StandardError ; end

  class << self
    def build(&block)
      builder = ConversionBuilder.new
      builder.instance_eval(&block)

      Class.new(Measurable) do
        class << self
          attr_reader :conversion
        end

        @conversion = builder.conversion
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
require "measured/unit"
require "measured/conversion"
require "measured/conversion_builder"
require "measured/conversion_table"
require "measured/measurable"
