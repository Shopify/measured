class Measured::Length < Measured::Measurable

  conversion.set_base :m,
    aliases: [:meter, :metre, :meters, :metres]

  conversion.add :cm,
    aliases: [:centimeter, :centimetre, :centimeters, :centimetres],
    value: "0.01 m"

  conversion.add :mm,
    aliases: [:millimeter, :millimetre, :millimeters, :millimetres],
    value: "0.001 m"

  conversion.add :in,
    aliases: [:inch, :inches],
    value: "0.0254 m"

  conversion.add :ft,
    aliases: [:foot, :feet],
    value: "0.3048 m"

  conversion.add :yd,
    aliases: [:yard, :yards],
    value: "0.9144 m"

end
