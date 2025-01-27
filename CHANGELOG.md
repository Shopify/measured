Unreleased
-----

3.2.0
-----
* Make the ActiveRecord validation errors have the correct type. (@alexcarruthers)

3.1.0
-----
* Drop support for Rails 6 and Ruby 3.0.
* Add qunitals. Add aliases for UK ton/tonne. (@ragarwal6397)


3.0.0
-----

* Merge functionality of `measured-rails` into this gem. From this version on, this gem is able to automatically integrate with Active Record out of the box. (@paracycle)
* Add `:gm` and `:gms` as aliases to weight. (@kushagra-03)
* Adds support for initializing `Measured` objects with a rational value from string. (@dvisockas)
* Make `Measured` initialization faster by avoiding string substitution in certain cases. (@bitwise-aiden)

2.8.2
-----

* Add cm3 and mm3 to volume. (@fekadeabdejene)

2.8.1
-----

* Allow format without the conversion string. (@saraid)
* Add special case for zero coercion to allow direct use of `sum` method. (@jmortlock)
* Add useful numeric methods `finite?`, `infinite?`, `zero?`, `nonzero?`, `positive?` and `negative?`. (@jmortlock)

2.8.0
-----

* Drop support for Ruby 2.5
* Use Ruby 3.0.2 for development

2.7.1
-----

* Fix Ruby 3.0 compatibility

2.7.0
-----

* Raises an exception on cyclic conversions. (@arturopie)
* Deduplicate strings loaded from the cache.
* Deduplicate parsed units.

2.6.0
-----

* Add `Measured::MissingConversionPath` and `Measured::UnitAlreadyAdded` as subclasses of `Measured::UnitError` to handle specific error cases. (@arturopie)
* Support only ActiveSupport 5.2 and above.


2.5.2
-----

* Allow unit values to be declared in the unit system through aliases and not just the base unit name.
* Fix some deprecations in tests and CI.

2.5.1
----

* Get rid of most memoizations in favor of eager computations.

2.5.0
-----

* Add `CHANGELOG.md`.
* Fix some deprecations and warnings.
* Support Rails 6 and Ruby 2.6.
* Cache conversion table in JSON file for first load performance.
