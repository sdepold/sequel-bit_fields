# sequel-bit-fields

This is a plugin for [Sequel](http://sequel.rubyforge.org/) which allows the creation of bitfields.
With bitfields you can define flags / booleans / bits /whatsoever for you model.

## usage

    require 'sequel-bit-fields'

    class MyModel < Sequel::Model
      # generic:
      plugin :bit_fields, :the_respective_column, [ :the, :different, :flags, :or, :bits ]

      # real world:
      plugin :bit_fields, :status_bits, [ :started, :finished, :reviewed ]
    end

    model = MyModel.create

    model.started?       // => false
    model.started = true
    model.started?       // => true
    model.status_bits    // => 1

    model.finished = true
    model.finished?      // => true
    model.status_bits    // => 3

## the table

    DB = Sequel.sqlite

    DB.create_table(:spec) do
      primary_key :id, :auto_increment => true

      # let's use Bignum as it has more space :)
      # set the default to 0 and disallow null values
      Bignum :status_bits, :null => false, :default => 0
    end

## installation

    # gem approach
    gem install sequel-bit-fields

    # bundler approach
    # add this to your Gemfile
    gem 'sequel-bit-fields'

## side notes

You should always declare the column with a default value of 0. Also NULL should be disabled / not allowed.
Otherwise the plugin will fail hard!

## License
Hereby released under MIT license.

## Authors/Contributors

- BlackLane GmbH
- Sascha Depold ([Twitter](http://twitter.com/sdepold) | [Github](http://github.com/sdepold) | [Website](http://depold.com))
