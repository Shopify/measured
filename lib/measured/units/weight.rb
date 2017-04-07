Measured::Weight = Measured.build do
  unit :g, aliases: [:gram, :grams]
  unit :kg, value: "1000 g", aliases: [:kilogram, :kilograms]
  unit :t, value: "1000 kg", aliases: ['metric tonne', 'metric tonnes']
  unit :slug, value: "14.593903 kg", aliases: [:slugs]
  unit :N, value: "0.10197162129779283 kg", aliases: [:newtons, :newton]
  unit :long_ton, value: "2240 lb", aliases: [:long_tons, 'long ton', 'long tons', 'weight ton', 'weight tons', 'W/T']
  unit :short_ton, value: "2000 lb", aliases: [:short_tons, 'short ton', 'short tons']
  unit :lb, value: "0.45359237 kg", aliases: [:lbs, :pound, :pounds]
  unit :oz, value: "1/16 lb", aliases: [:ounce, :ounces]
end
