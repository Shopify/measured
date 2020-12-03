# frozen_string_literal: true
require "forwardable"
require "measured/version"
require "active_support/all"
require "bigdecimal"
require "json"

module Measured
  class UnitError < StandardError ; end
  class UnitAlreadyAdded < UnitError
    attr_reader :unit_name

    def initialize(unit_name)
      @unit_name = unit_name
      super("Unit #{unit_name} has already been added.")
    end
  end

  class << self
    def build(&block)
      builder = UnitSystemBuilder.new
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
      klass = class_name.safe_constantize

      if klass && klass < Measurable
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
require "measured/parser"
require "measured/unit"
require "measured/unit_system"
require "measured/unit_system_builder"
require "measured/conversion_table_builder"
require "measured/cache/null"
require "measured/cache/json_writer"
require "measured/cache/json"
require "measured/measurable"
