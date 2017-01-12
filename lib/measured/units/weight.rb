Measured::Weight = Measured.build do
  unit :g, aliases: [:gram, :grams]
  unit :kg, value: "1000 g", aliases: [:kilogram, :kilograms]
  unit :lb, value: "0.45359237 kg", aliases: [:lbs, :pound, :pounds]
  unit :oz, value: "1/16 lb", aliases: [:ounce, :ounces]
end
