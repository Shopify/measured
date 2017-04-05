Measured::Weight = Measured.build do
  unit :g, aliases: [:gram, :grams]
  unit :kg, value: "1000 g", aliases: [:kilogram, :kilograms]
  unit :T, value: "1000 kg", aliases: [:tonne, :tonnes]
  unit :slug, value: "14.5939 kg", aliases: [:slugs]
  unit :N, value: "9.807 kg", aliases: [:newtons, :newton]
  unit :t, value: "2000 lb", aliases: [:ton, :tons]
  unit :lb, value: "0.45359237 kg", aliases: [:lbs, :pound, :pounds]
  unit :oz, value: "1/16 lb", aliases: [:ounce, :ounces]
end
