# Change Log
All notable changes to this project will be documented in this file.

## Upcoming
### Changed
- Use keepachangelog format for this change log

## v1.2.1
### Changed
- Fix quotation for postgres.

## v1.2.0
### Changed
- Added shorthand assignments.

## v1.1.1
### Changed
- Sequel removed some core extensions. Regression has been taken into account.

## v1.1.0
### Changed
- defined methods to the instances that reflects the value of the bitfield

## v1.0.0
### Changed
- bit-field symbols are transformed into objects
- this allows to add additional information to the bit-fields like description and such thingies.

## v0.9.0
### Changed
- added possibility to specify relevant values for bit_field_values_for

## v0.8.0
### Changed
- added possibilty to define the table name when using `_sql` methods

## v0.7.0
### Changed
- fixed interpretation of bit_fields passed to the constructor
- fixed compatibility of Model.new
- added scoping of bit_fields

## v0.6.0
### Changed
- added support for truthy or falsy values
- fixed setting of false if bit_fields was previously already false

## v0.5.1
### Changed
- class methods used to get defined for all classes. this is fixed.

## v0.5.0
### Changed
- added method that returns a hash of defined columns and it's indexes
- added method that returns a hash of defined columns and it's values

## v0.4.0
### Changed
- added methods that returns the defined columns and it's attributes
- use fully qualified column names in sql statements

## v0.3.0
### Changed
- fixed folder structure

## v0.2.0
### Changed
- support for Model.field_sql(boolean) added
- increased speed by calculating 2**i only once

## v0.1.0, v0.1.1
### Changed
- first working version
- support for field= and field? added
