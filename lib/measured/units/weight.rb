Measured::Weight = Measured.build do
  base :g, aliases: [:gram, :grams]

  unit :kg, value: "1000 g", aliases: [:kilogram, :kilograms]
  unit :oz, value: [Rational(1, 16), "lb"], aliases: [:ounce, :ounces]
  unit :lb, value: [Rational(45359237, 1e8), "kg"], aliases: [:lbs, :pound, :pounds]
end
