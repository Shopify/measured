class Measured::CaseSensitiveMeasurable < Measured::Measurable
  class << self
    def conversion
      @conversion ||= Measured::Conversion.new(case_sensitive: true)
    end
  end
end
