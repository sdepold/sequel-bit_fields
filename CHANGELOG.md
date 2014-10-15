# v1.2.1
- Fix quotation for postgres.

# v1.2.0
- Added shorthand assignments.

# v1.1.1
- Sequel removed some core extensions. Regression has been taken into account.

# v1.1.0
- defined methods to the instances that reflects the value of the bitfield

# v1.0.0
- bit-field symbols are transformed into objects
- this allows to add additional information to the bit-fields like description and such thingies.

# v0.9.0
- added possibility to specify relevant values for bit_field_values_for

# v0.8.0
- added possibilty to define the table name when using `_sql` methods

# v0.7.0
- fixed interpretation of bit_fields passed to the constructor
- fixed compatibility of Model.new
- added scoping of bit_fields

# v0.6.0
- added support for truthy or falsy values
- fixed setting of false if bit_fields was previously already false

# v0.5.1
- class methods used to get defined for all classes. this is fixed.

# v0.5.0
- added method that returns a hash of defined columns and it's indexes
- added method that returns a hash of defined columns and it's values

# v0.4.0
- added methods that returns the defined columns and it's attributes
- use fully qualified column names in sql statements

# v0.3.0
- fixed folder structure

# v0.2.0
- support for Model.field_sql(boolean) added
- increased speed by calculating 2**i only once

# v0.1.0, v0.1.1
- first working version
- support for field= and field? added
