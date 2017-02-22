# Measured [![Build Status](https://travis-ci.org/Shopify/measured.svg)](https://travis-ci.org/Shopify/measured) [![Gem Version](https://badge.fury.io/rb/measured.svg)](http://badge.fury.io/rb/measured)

Encapsulates measurements with their units. Provides easy conversion between units.

Lightweight and easily extensible to include other units and conversions. Conversions done with `Rational` for precision.

The adapter to integrate `measured` with Ruby on Rails is in a separate [`measured-rails`](https://github.com/Shopify/measured-rails) gem.

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
```

Convert to return a new measurement:

```ruby
Measured::Weight.new("12", "g").convert_to("kg")
```

Agnostic to symbols/strings:

```ruby
Measured::Weight.new(1, "kg") == Measured::Weight.new(1, :kg)
```

Seamlessly handles aliases:

```ruby
Measured::Weight.new(12, :oz) == Measured::Weight.new("12", :ounce)
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
> #<Measured::Weight 123 g>
```

Parse can scrub extra whitespace and split number from unit:

```ruby
Measured::Weight.parse(" 2kg ")
> #<Measured::Weight 2 kg>
```

Perform addition / subtraction against other units, all represented internally as `Rational` or `BigDecimal`:

```ruby
Measured::Weight.new(1, :g) + Measured::Weight.new(2, :g)
> #<Measured::Weight 3 g>
Measured::Weight.new("2.1", :g) - Measured::Weight.new(1, :g)
> #<Measured::Weight 1.1 g>
```

Multiplication and division by units is not supported, but the actual value can be scaled by a scalar:

```ruby
Measured::Weight.new(10, :g).scale(0.5)
> #<Measured::Weight 5 g>
Measured::Weight.new(2, :g).scale(3)
> #<Measured::Weight 6 g>
```

In cases of differing units, the left hand side takes precedence:

```ruby
Measured::Weight.new(1000, :g) + Measured::Weight.new(1, :kg)
> #<Measured::Weight 2000 g>
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
> #<BigDecimal 1.2>
weight.unit
> "g"
```

See all valid units:

```ruby
Measured::Weight.units
> ["g", "kg", "lb", "oz"]
```

Check if a unit is a valid unit or alias:

```ruby
Measured::Weight.valid_unit?(:g)
> true
Measured::Weight.valid_unit?("gram")
> true
Measured::Weight.valid_unit?("stone")
> false
```

See all valid units with their aliases:

```ruby
Measured::Weight.units_with_aliases
> ["g", "gram", "grams", "kg", "kilogram", "kilograms", "lb", "lbs", "ounce", "ounces", "oz", "pound", "pounds"]
```

## Units and conversions

### Bundled unit conversion

* `Measured::Weight`
  * g, gram, grams
  * kg, kilogram, kilograms
  * lb, lbs, pound, pounds
  * oz, ounce, ounces
* `Measured::Length`
  * m, meter, metre, meters, metres
  * cm, centimeter, centimetre, centimeters, centimetres
  * mm, millimeter, millimetre, millimeters, millimetres
  * in, inch, inches
  * ft, foot, feet
  * yd, yard, yards

You can skip these and only define your own units by doing:

```ruby
gem 'measured', require: 'measured/base'
```

### Shortcut syntax

There is a shortcut initialization syntax for modules inside the `Measured` namespace, similar to `BigDecimal(123)` vs `BigDecimal.new(123)`:

```ruby
Measured::Weight(1, :g)
```

### Adding new units

Extending this library to support other units is simple. To add a new conversion, use `Measured.build` to define your base unit and conversion units:

```ruby
Measured::Thing = Measured.build do
  unit :base_unit,           # Add a unit to the system
    aliases: [:bu]           # Allow it to be aliased to other names/symbols

  unit :another_unit,        # Add a second unit to the system
    aliases: [:au],          # All units allow aliases, as long as they are unique
    value: ["1.5 bu"]        # The conversion rate to another unit
end
```

All unit names are case sensitive.

Values for conversion units can be defined as a string with two tokens `"number unit"` or as an array with two elements. All values will be parsed as / coerced to `Rational`. Conversion paths don't have to be direct as a conversion table will be built for all possible conversions.

### Namespaces

All units and classes are namespaced by default, but can be aliased in your application.

```ruby
Weight = Measured::Weight
Length = Measured::Length
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
  * No ActiveRecord adapter.

### Gem: [quantified](https://github.com/Shopify/quantified)
* **Pros**
  * Lightweight.
  * Included with ActiveShipping/ActiveUtils.
* **Cons**
  * All math done with floats making it highly lossy.
  * All units assumed to be pluralized, meaning using unit abbreviations is not possible.
  * Not actively maintained.
  * No ActiveRecord adapter.

### Gem: [unitwise](https://github.com/joshwlewis/unitwise)
* **Pros**
  * Well written and maintained.
  * Conversions done with  Unified Code for Units of Measure (UCUM) so highly accurate and reliable.
* **Cons**
  * Lots of code. Good code, but lots of it.
  * Many modifications to core types.
  * ActiveRecord adapter exists but is written and maintained by a different person/org.

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
