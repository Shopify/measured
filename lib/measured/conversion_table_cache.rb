class Measured::ConversionTableCache
  attr_reader :filename

  def initialize(filename)
    @filename = filename
    @path = File.join(File.dirname(__FILE__), "../../cache", @filename) if @filename
  end

  def exist?
    return false unless filename

    File.exist?(@path)
  end

  def read
    return nil unless exist?

    decode(JSON.load(File.read(@path)))
  end

  def write(table)
    return nil unless @path

    File.open(@path, "w") do |f|
      f.write("// Do not modify this file directly. Regenerate it with 'rake cache:write'.\n")
      f.write(encode(table).to_json)
    end
  end

  private

  # JSON dump and load of Rational objects exists, but it changes the behaviour of JSON globally if required.
  # Instead, the same marhalling technique is rewritten here to prevent changing this behaviour project wide.
  # https://github.com/ruby/ruby/blob/trunk/ext/json/lib/json/add/rational.rb
  def encode(table)
    encoded = table.dup

    encoded.each do |k1, v1|
      v1.each do |k2, v2|
        if v2.is_a?(Rational)
          encoded[k1][k2] = { "numerator" => v2.numerator, "denominator" => v2.denominator }
        end
      end
    end

    encoded
  end

  def decode(table)
    decoded = table.dup

    decoded.each do |k1, v1|
      v1.each do |k2, v2|
        if v2.is_a?(Hash)
          decoded[k1][k2] = Rational(v2["numerator"], v2["denominator"])
        end
      end
    end

    decoded
  end
end
