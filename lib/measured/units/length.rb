Measured::Length = Measured.build do
  unit :m, aliases: [:meter, :metre, :meters, :metres]
  unit :cm, value: "0.01   m", aliases: [:centimeter, :centimetre, :centimeters, :centimetres]
  unit :mm, value: "0.001  m", aliases: [:millimeter, :millimetre, :millimeters, :millimetres]
  unit :in, value: "0.0254 m", aliases: [:inch, :inches]
  unit :ft, value: "0.3048 m", aliases: [:foot, :feet]
  unit :yd, value: "0.9144 m", aliases: [:yard, :yards]
end
