# Measured [![Build Status](https://github.com/Shopify/measured/workflows/CI/badge.svg)](https://github.com/Shopify/measured/actions?query=workflow%3ACI)

Encapsulates measurements with their units. Provides easy conversion between units. Built in support for weight, length, and volume.

Lightweight and easily extensible to include other units and conversions. Conversions done with `Rational` for precision.

Since version 3.0.0, the adapter to integrate `measured` with Ruby on Rails is also a part of this gem. If you had been using [`measured-rails`](https://github.com/Shopify/measured-rails) for that functionality, you should now remove `measured-rails` from your gem file.

## Installation

Using bundler, add to the Gemfile:

```ruby
gem 'measured'
```

Or stand alone:

```
$ gem install measured
```

## Usage

Initialize a measurement:

```ruby
Measured::Weight.new("12", "g")
> #<Measured::Weight: 12 #<Measured::Unit: g (gram, grams)>>
```

Convert to return a new measurement:

```ruby
Measured::Weight.new("12", "g").convert_to("kg")
> #<Measured::Weight: 0.012 #<Measured::Unit: kg (kilogram, kilograms) 1000/1 g>>
```

Agnostic to symbols/strings:

```ruby
Measured::Weight.new(1, "kg") == Measured::Weight.new(1, :kg)
> true
```

Seamlessly handles aliases:

```ruby
Measured::Weight.new(12, :oz) == Measured::Weight.new("12", :ounce)
> true
```

Raises on unknown units:

```ruby
begin
  Measured::Weight.new(1, :stone)
rescue Measured::UnitError
  puts "Unknown unit"
end
```

Parse from string without having to split out the value and unit first:

```ruby
Measured::Weight.parse("123 grams")
> #<Measured::Weight: 123 #<Measured::Unit: g (gram, grams)>>
```

Parse can scrub extra whitespace and split number from unit:

```ruby
Measured::Weight.parse(" 2kg ")
> #<Measured::Weight: 2 #<Measured::Unit: kg (kilogram, kilograms) 1000/1 g>>
```

Perform addition / subtraction against other units, all represented internally as `Rational` or `BigDecimal`:

```ruby
Measured::Weight.new(1, :g) + Measured::Weight.new(2, :g)
> #<Measured::Weight: 3 #<Measured::Unit: g (gram, grams)>>
Measured::Weight.new("2.1", :g) - Measured::Weight.new(1, :g)
> #<Measured::Weight: 1.1 #<Measured::Unit: g (gram, grams)>>
```

Multiplication and division by units is not supported, but the actual value can be scaled by a scalar:

```ruby
Measured::Weight.new(10, :g).scale(0.5)
> #<Measured::Weight: 5 #<Measured::Unit: g (gram, grams)>>
Measured::Weight.new(2, :g).scale(3)
> #<Measured::Weight: 6 #<Measured::Unit: g (gram, grams)>>
```

In cases of differing units, the left hand side takes precedence:

```ruby
Measured::Weight.new(1000, :g) + Measured::Weight.new(1, :kg)
> #<Measured::Weight: 2000 #<Measured::Unit: g (gram, grams)>>
```

Converts units only as needed for equality comparison:

```ruby
> Measured::Weight.new(1000, :g) == Measured::Weight.new(1, :kg)
true
```

Extract the unit and the value:

```ruby
weight = Measured::Weight.new("1.2", "grams")
weight.value
> #<BigDecimal:7fabf6c1d0a0,'0.12E1',18(18)>
weight.unit
> #<Measured::Unit: g (gram, grams)>
```

See all valid units:

```ruby
Measured::Weight.unit_names
> ["g", "kg", "lb", "oz"]
```

Check if a unit is a valid unit or alias:

```ruby
Measured::Weight.unit_or_alias?(:g)
> true
Measured::Weight.unit_or_alias?("gram")
> true
Measured::Weight.unit_or_alias?("stone")
> false
```

See all valid units with their aliases:

```ruby
Measured::Weight.unit_names_with_aliases
> ["g", "gram", "grams", "kg", "kilogram", "kilograms", "lb", "lbs", "ounce", "ounces", "oz", "pound", "pounds"]
```

String formatting:
```ruby
Measured::Weight.new("3.14", "grams").format("%.1<value>f %<unit>s")
> "3.1 g"
```

If no string is passed to the `format` method it defaults to `"%.2<value>f %<unit>s"`.

If the unit isn't the standard SI unit, it will include a conversion string.

```ruby
Measured::Weight.new("3.14", "kg").format
> "3.14 kg (1000/1 g)"
Measured::Weight.new("3.14", "kg").format(with_conversion_string: false)
> "3.14 kg"
```

### Active Record

This gem also provides an Active Record adapter for persisting and retrieving measurements with their units, and model validations.

Columns are expected to have the `_value` and `_unit` suffix, and be `DECIMAL` and `VARCHAR`, and defaults are accepted. Customizing the column used to hold units is supported, see below for details.

```ruby
class AddWeightAndLengthToThings < ActiveRecord::Migration
  def change
    add_column :things, :minimum_weight_value, :decimal, precision: 10, scale: 2
    add_column :things, :minimum_weight_unit, :string, limit: 12

    add_column :things, :total_length_value, :decimal, precision: 10, scale: 2, default: 0
    add_column :things, :total_length_unit, :string, limit: 12, default: "cm"
  end
end
```

A column can be declared as a measurement with its measurement subclass:

```ruby
class Thing < ActiveRecord::Base
  measured Measured::Weight, :minimum_weight
  measured Measured::Length, :total_length
  measured Measured::Volume, :total_volume
end
```

You can optionally customize the model's unit column by specifying it in the `unit_field_name` option, as follows:

```ruby
class ThingWithCustomUnitAccessor < ActiveRecord::Base
  measured_length :length, :width, :height,     unit_field_name: :size_unit
  measured_weight :total_weight, :extra_weight, unit_field_name: :weight_unit
  measured_volume :total_volume, :extra_volume, unit_field_name: :volume_unit
end
```

Similarly, you can optionally customize the model's value column by specifying it in the `value_field_name` option, as follows:

```ruby
class ThingWithCustomValueAccessor < ActiveRecord::Base
  measured_length :length, value_field_name: :custom_length
  measured_weight :total_weight, value_field_name: :custom_weight
  measured_volume :volume, value_field_name: :custom_volume
end
```

There are some simpler methods for predefined types:

```ruby
class Thing < ActiveRecord::Base
  measured_weight :minimum_weight
  measured_length :total_length
  measured_volume :total_volume
end
```

This will allow you to access and assign a measurement object:

```ruby
thing = Thing.new
thing.minimum_weight = Measured::Weight.new(10, "g")
thing.minimum_weight_unit     # "g"
thing.minimum_weight_value    # 10
```

Order of assignment does not matter, and each property can be assigned separately and with mass assignment:

```ruby
params = { total_length_unit: "cm", total_length_value: "3" }
thing = Thing.new(params)
thing.total_length.to_s   # 3 cm
```

### Validations

Validations are available:

```ruby
class Thing < ActiveRecord::Base
  measured_length :total_length

  validates :total_length, measured: true
end
```

This will validate that the unit is defined on the measurement, and that there is a value.

Rather than `true` the validation can accept a hash with the following options:

* `message`: Override the default "is invalid" message.
* `units`: A subset of units available for this measurement. Units must be in existing measurement.
* `greater_than`
* `greater_than_or_equal_to`
* `equal_to`
* `less_than`
* `less_than_or_equal_to`

All comparison validations require `Measured::Measurable` values, not scalars. Most of these options replace the `numericality` validator which compares the measurement/method name/proc to the column's value. Validations can also be combined with `presence` validator.

**Note:** Validations are strongly recommended since assigning an invalid unit will cause the measurement to return `nil`, even if there is a value:

```ruby
thing = Thing.new
thing.total_length_value = 1
thing.total_length_unit = "invalid"
thing.total_length  # nil
```

## Units and conversions

### SI units support

There is support for SI units through the use of `si_unit`. Units declared through it will have automatic support for all SI prefixes:

| Multiplying Factor                | SI Prefix | Scientific Notation   |
| --------------------------------- | --------- | --------------------- |
| 1 000 000 000 000 000 000 000 000 | yotta (Y) | 10^24                 |
| 1 000 000 000 000 000 000 000     | zetta (Z) | 10^21                 |
| 1 000 000 000 000 000 000         | exa (E)   | 10^18                 |
| 1 000 000 000 000 000             | peta (P)  | 10^15                 |
| 1 000 000 000 000                 | tera (T)  | 10^12                 |
| 1 000 000 000                     | giga (G)  | 10^9                  |
| 1 000 000                         | mega (M)  | 10^6                  |
| 1 000                             | kilo (k)  | 10^3                  |
| 0.001                             | milli (m) | 10^-3                 |
| 0.000 001                         | micro (µ) | 10^-6                 |
| 0.000 000 001                     | nano (n)  | 10^-9                 |
| 0.000 000 000 001                 | pico (p)  | 10^-12                |
| 0.000 000 000 000 001             | femto (f) | 10^-15                |
| 0.000 000 000 000 000 001         | atto (a)  | 10^-18                |
| 0.000 000 000 000 000 000 001     | zepto (z) | 10^-21                |
| 0.000 000 000 000 000 000 000 001 | yocto (y) | 10^-24                |

### Bundled unit conversion

* `Measured::Weight`
  * g, gram, grams, and all SI prefixes
  * t, metric_ton, metric_tons
  * slug, slugs
  * N, newtons, newton
  * long_ton, long_tons, weight_ton, weight_tons, 'W/T', imperial_ton, imperial_tons, displacement_ton, displacement_tons
  * short_ton, short_tons
  * lb, lbs, pound, pounds
  * oz, ounce, ounces
* `Measured::Length`
  * m, meter, metre, meters, metres, and all SI prefixes
  * in, inch, inches
  * ft, foot, feet
  * yd, yard, yards
  * mi, mile, miles
* `Measured::Volume`
  * l, liter, litre, liters, litres, and all SI prefixes
  * m3, cubic_meter, cubic_meters, cubic_metre, cubic_metres
  * ft3, cubic_foot, cubic_feet
  * in3, cubic_inch, cubic_inches
  * gal, imp_gal, imperial_gallon, imp_gals, imperial_gallons
  * us_gal, us_gallon, us_gals, us_gallons
  * qt, imp_qt, imperial_quart, imp_qts, imperial_quarts
  * us_qt, us_quart, us_quarts
  * pt, imp_pt, imperial_pint, imp_pts, imperial_pints
  * us_pt, us_pint, us_pints
  * oz, fl_oz, imp_fl_oz, imperial_fluid_ounce, imperial_fluid_ounces
  * us_oz, us_fl_oz, us_fluid_ounce, us_fluid_ounces

You can skip these and only define your own units by doing:

```ruby
gem 'measured', require: 'measured/base'
```

### Shortcut syntax

There is a shortcut initialization syntax for creating instances of measurement classes that can avoid the `.new`:

```ruby
Measured::Weight(1, :g)
> #<Measured::Weight: 1 #<Measured::Unit: g (gram, grams)>>
```

### Adding new units

Extending this library to support other units is simple. To add a new conversion, use `Measured.build` to define your base unit and conversion units:

```ruby
Measured::Thing = Measured.build do
  unit :base_unit,           # Add a unit to the system
    aliases: [:bu]           # Allow it to be aliased to other names/symbols

  unit :another_unit,        # Add a second unit to the system
    aliases: [:au],          # All units allow aliases, as long as they are unique
    value: "1.5 bu"        # The conversion rate to another unit
end
```

All unit names are case sensitive.

Values for conversion units can be defined as a string with two tokens `"number unit"` or as an array with two elements. All values will be parsed as / coerced to `Rational`. Conversion paths don't have to be direct as a conversion table will be built for all possible conversions.

### Namespaces

All units and classes are namespaced by default, but can be aliased in your application.

```ruby
Weight = Measured::Weight
Length = Measured::Length
Volume = Measured::Volume
```

## Alternatives

Existing alternatives which were considered:

### Gem: [ruby-units](https://github.com/olbrich/ruby-units)
* **Pros**
  * Accurate math and conversion factors.
  * Includes nearly every unit you could ask for.
* **Cons**
  * Opens up and modifies `Array`, `Date`, `Fixnum`, `Math`, `Numeric`, `String`, `Time`, and `Object`, then depends on those changes internally.
  * Lots of code to solve a relatively simple problem.
  * No Active Record adapter.

### Gem: [quantified](https://github.com/Shopify/quantified)
* **Pros**
  * Lightweight.
* **Cons**
  * All math done with floats making it highly lossy.
  * All units assumed to be pluralized, meaning using unit abbreviations is not possible.
  * Not actively maintained.
  * No Active Record adapter.

### Gem: [unitwise](https://github.com/joshwlewis/unitwise)
* **Pros**
  * Well written.
  * Conversions done with Unified Code for Units of Measure (UCUM) so highly accurate and reliable.
* **Cons**
  * Lots of code. Good code, but lots of it.
  * Many modifications to core types.
  * Active Record adapter exists but is written and maintained by a different person/org.
  * Not actively maintained.

## Contributing

1. Fork it ( https://github.com/Shopify/measured/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Authors

* [Kevin McPhillips](https://github.com/kmcphillips) at [Shopify](http://shopify.com/careers)
* [Sai Warang](https://github.com/cyprusad) at [Shopify](http://shopify.com/careers)
* [Gareth du Plooy](https://github.com/garethson) at [Shopify](http://shopify.com/careers)
