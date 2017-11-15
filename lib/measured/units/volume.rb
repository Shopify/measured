Measured::Volume = Measured.build do
  si_unit :l, aliases: [:liter, :litre, :liters, :litres]

  unit :m3, value: "1000 l", aliases: [:cubic_meter, :cubic_metre, :cubic_meters, :cubic_metres]
  unit :ft3, value: "0.0353147 l", aliases: [:cubic_foot, :cubic_feet]
  unit :in3, value: "1728 ft3", aliases: [:cubic_inch, :cubic_inches]
  unit :gal, value: "0.00454609 m3", aliases: [:imp_gal, :imperial_gallon, :imp_gals,:imperial_gallons]
  unit :us_gal, value: "0.00378541 m3", aliases: [:us_gallon, :us_gals, :us_gallons]
  unit :qt, value: "0.25 gal", aliases: [:imp_qt, :imperial_quart, :imp_qts, :imperial_quarts]
  unit :us_qt, value: "0.25 us_gal", aliases: [:us_quart, :us_quarts]
  unit :pt, value: "0.125 gal", aliases: [:imp_pt, :imperial_pint, :imp_pts, :imperial_pints]
  unit :us_pt, value: "0.125 us_gal", aliases: [:us_pint, :us_pints]
  unit :oz, value: "0.00625 gal", aliases: [:fl_oz, :imp_fl_oz, :fluid_ounce, :imperial_fluid_ounce, :fluid_ounces, :imperial_fluid_ounces]
  unit :us_oz, value: "0.0078125 us_gal", aliases: [:us_fl_oz, :us_fluid_ounce, :us_fluid_ounces]
end