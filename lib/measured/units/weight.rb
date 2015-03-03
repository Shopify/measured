class Measured::Weight < Measured::Measurable

  conversion.set_base :g,
    aliases: [:gram, :grams]

  conversion.add :kg,
    aliases: [:kilogram, :kilograms],
    value: "1000 g"

  conversion.add :lb,
    aliases: [:lbs, :pound, :pounds],
    value: [Rational(45359237,1e8), "kg"]

  conversion.add :oz,
    aliases: [:ounce, :ounces],
    value: [Rational(1,16), "lb"]

end
