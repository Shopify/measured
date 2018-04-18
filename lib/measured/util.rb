module Measured
  class << self
    alias_method :old_build, :build

    def build(**kwargs, &block)
      measurable = old_build(**kwargs, &block)
      add_extensions(measurable)
      measurable
    end

    private

    def add_extensions(measurable)
      measurable.units_with_aliases.each do |name|
        Numeric.class_eval do
          define_method(name) { measurable.new(self, name) }
        end
      end
    end
  end

  add_extensions(Measured::Length) if defined?(Measured::Length)
  add_extensions(Measured::Weight) if defined?(Measured::Weight)
end
