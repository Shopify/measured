Unreleased
-----

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
