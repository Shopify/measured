# frozen_string_literal: true
Measured::Volume = Measured.build do
  si_unit :l, aliases: [:liter, :litre, :liters, :litres]

  unit :m3, value: "1000 l", aliases: [:cubic_meter, :cubic_metre, :cubic_meters, :cubic_metres]
  unit :cm3, value: "0.001 l", aliases: [:cubic_centimeter, :cubic_centimetre, :cubic_centimeters, :cubic_centimetres]
  unit :mm3, value: "0.000001 l", aliases: [:cubic_millimeter, :cubic_millimetre, :cubic_millimeters, :cubic_millimetres]
  unit :in3, value: "0.016387064 l", aliases: [:cubic_inch, :cubic_inches]
  unit :ft3, value: "1728 in3", aliases: [:cubic_foot, :cubic_feet]
  unit :gal, value: "4.54609 l", aliases: [:imp_gal, :imperial_gallon, :imp_gals, :imperial_gallons]
  unit :us_gal, value: "231 in3", aliases: [:us_gallon, :us_gals, :us_gallons]
  unit :qt, value: "0.25 gal", aliases: [:imp_qt, :imperial_quart, :imp_qts, :imperial_quarts]
  unit :us_qt, value: "0.25 us_gal", aliases: [:us_quart, :us_quarts]
  unit :pt, value: "0.125 gal", aliases: [:imp_pt, :imperial_pint, :imp_pts, :imperial_pints]
  unit :us_pt, value: "0.125 us_gal", aliases: [:us_pint, :us_pints]
  unit :oz, value: "0.00625 gal", aliases: [:floz, :fl_oz, :imp_fl_oz, :imperial_fluid_ounce, :imperial_fluid_ounces]
  unit :us_oz, value: "0.0078125 us_gal", aliases: [:us_fl_oz, :us_fluid_ounce, :us_fluid_ounces]

  cache Measured::Cache::Json, "volume.json"
end
