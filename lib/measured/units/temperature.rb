# frozen_string_literal: true
Measured::Temperature = Measured.build do
  unit :C, aliases: [:celsius]

  unit :K, aliases: [:kelvin], convert_to: "C",
    forward: ->(k) { k - BigDecimal("273.15") },
    backward: ->(c) { c + BigDecimal("273.15") },
    description: "celsius + 273.15"

  unit :F, aliases: [:fahrenheit], convert_to: "C",
    forward: ->(f) { (f - 32) * Rational(5, 9) },
    backward: ->(c) { c * Rational(9, 5) + 32 },
    description: "celsius * 9/5 + 32"
end
