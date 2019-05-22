# frozen_string_literal: true
Measured::Length = Measured.build do
  si_unit :m, aliases: [:meter, :metre, :meters, :metres]

  unit :in, value: "0.0254 m", aliases: [:inch, :inches]
  unit :ft, value: "12 in", aliases: [:foot, :feet]
  unit :yd, value: "3 ft", aliases: [:yard, :yards]
  unit :mi, value: "5280 ft", aliases: [:mile, :miles]

  cache Measured::Cache::Json, "length.json"
end
