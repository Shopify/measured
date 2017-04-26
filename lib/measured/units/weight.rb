Measured::Weight = Measured.build do
  unit :g, aliases: [:gram, :grams]
  unit :kg, value: "1000 g", aliases: [:kilogram, :kilograms]
  unit :t, value: "1000 kg", aliases: [:metric_ton, :metric_tons]
  unit :slug, value: "14.593903 kg", aliases: [:slugs]
  unit :N, value: "0.10197162129779283 kg", aliases: [:newtons, :newton]
  unit :long_ton, value: "2240 lb", aliases: [:long_tons, :weight_ton, :weight_tons, 'W/T', :imperial_ton, :imperial_tons, :displacement_ton, :displacement_tons]
  unit :short_ton, value: "2000 lb", aliases: [:short_tons]
  unit :lb, value: "0.45359237 kg", aliases: [:lbs, :pound, :pounds]
  unit :oz, value: "1/16 lb", aliases: [:ounce, :ounces]
end
