# frozen_string_literal: true
module Measured::Cache
  class Json
    attr_reader :filename, :path

    def initialize(filename)
      @filename = filename
      raise ArgumentError, "Invalid cache file: #{filename}" unless %w[length.json weight.json volume.json test.json].include?(filename.to_s)
      @path = Pathname.new(File.join(File.dirname(__FILE__), "../../../cache", filename)).cleanpath
    end

    def exist?
      File.exist?(@path)
    end

    def read
      return unless exist?
      decode(JSON.load(File.read(@path), nil, freeze: true))
    end

    def write(table)
      raise ArgumentError, "Cannot overwrite file cache at runtime."
    end

    private

    # JSON dump and load of Rational objects exists, but it changes the behaviour of JSON globally if required.
    # Instead, the same marshalling technique is rewritten here to prevent changing this behaviour project wide.
    # https://github.com/ruby/ruby/blob/trunk/ext/json/lib/json/add/rational.rb
    def encode(table)
      table.each_with_object(table.dup) do |(k1, v1), accu|
        v1.each do |k2, v2|
          if v2.is_a?(Rational)
            accu[k1][k2] = { "numerator" => v2.numerator, "denominator" => v2.denominator }
          end
        end
      end
    end

    def decode(table)
      table.transform_values do |value1|
        if value1.is_a?(Hash)
          value1.transform_values do |value2|
            if value2.is_a?(Hash)
              Rational(value2["numerator"], value2["denominator"])
            else
              value2
            end
          end
        else
          value1
        end
      end
    end
  end
end
