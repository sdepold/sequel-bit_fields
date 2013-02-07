# sequel-bit-fields

This is a plugin for [Sequel](http://sequel.rubyforge.org/) which allows the creation of bitfields.
With bitfields you can define flags / booleans / bits /whatsoever for you model.

## Build status
[![Build Status](https://secure.travis-ci.org/sdepold/sequel-bit_fields.png)](http://travis-ci.org/sdepold/sequel-bit_fields)

## Usage

Let's define a model:

```ruby
class MyModel < Sequel::Model
  # generic:
  plugin :bit_fields, :the_respective_column, [ :the, :different, :flags, :or, :bits ]

  # real world:
  plugin :bit_fields, :status_bits, [ :started, :finished, :reviewed ]
end
```

And now we can play around with an instance of it:

```ruby
model = MyModel.create

model.started?        # => false
model.started = true
model.started?        # => true
model.status_bits     # => 1

model.finished?       # => false
model.finished = true
model.finished?       # => true
model.status_bits     # => 3
```

And we might want to find instances:

```ruby
# let's find all the finished instances
MyModel.where(MyModel.finished_sql(true)).all

# let's find all unfinished instances
MyModel.where(MyModel.finished_sql(false)).all

# let's find all the started and the finished instances
MyModel.where("#{ MyModel.started_sql(true) } AND #{ MyModel.finished_sql(true) }").all
```

If you need the declared columns:

```ruby
MyModel.bit_fields( :status_bits ) # => [ :started, :finished, :reviewed ]
```

Or... If you need the indexes of the columns:

```ruby
MyModel.bit_field_indexes_for( :status_bits ) # => { :started => 1, :finished => 2, :reviewed => 4}
```

Or... If you need the values of the declared columns:

```ruby
model = MyModel.new
model.finished => true
model.bit_field_values_for( :status_bits )
# => {:started => false, :finished => true, :reviewed => false}
```

## The table

If you are creating a new model from scratch:

    DB = Sequel.sqlite

    DB.create_table(:my_models) do
      primary_key :id, :auto_increment => true

      # let's use Bignum as it has more space :)
      # set the default to 0 and disallow null values
      Bignum :status_bits, :null => false, :default => 0
    end
    
##The migration

If you want to extend an existing model:

    Sequel.migration do
      change do
        alter_table :users do
          add_column :permission_bits, Bignum, :default => 0, :null => false
        end
      end
    end

## Installation

    # gem approach
    gem install sequel-bit_fields

    # bundler approach
    # add this to your Gemfile
    gem 'sequel-bit_fields'

## Side notes

You should always declare the column with a default value of 0. Also NULL should be disabled / not allowed.
Otherwise the plugin will fail hard!

## License
Hereby released under MIT license.

## Authors/Contributors

- BlackLane GmbH
- [Sascha Depold](http://depold.com) ([Twitter](http://twitter.com/sdepold) | [Github](http://github.com/sdepold))
