Measured::Length = Measured.build do
  unit :m, aliases: [:meter, :metre, :meters, :metres]
  unit :cm, value: "1/100 m", aliases: [:centimeter, :centimetre, :centimeters, :centimetres]
  unit :mm, value: "1/1000 m", aliases: [:millimeter, :millimetre, :millimeters, :millimetres]
  unit :in, value: "0.0254 m", aliases: [:inch, :inches]
  unit :ft, value: "12 in", aliases: [:foot, :feet]
  unit :yd, value: "3 ft", aliases: [:yard, :yards]
end
