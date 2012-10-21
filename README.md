# sequel-bit-fields

This is a plugin for [Sequel](http://sequel.rubyforge.org/) which allows the creation of bitfields.
With bitfields you can define flags / booleans / bits /whatsoever for you model.

[![Build Status](https://secure.travis-ci.org/sdepold/sequel-bit_fields.png)](http://travis-ci.org/sdepold/sequel-bit_fields)

## Usage

Let's define a model:

```ruby
require 'sequel-bit-fields'

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

model.started?       // => false
model.started = true
model.started?       // => true
model.status_bits    // => 1

model.finished?      // => false
model.finished = true
model.finished?      // => true
model.status_bits    // => 3
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

## The table

    DB = Sequel.sqlite

    DB.create_table(:spec) do
      primary_key :id, :auto_increment => true

      # let's use Bignum as it has more space :)
      # set the default to 0 and disallow null values
      Bignum :status_bits, :null => false, :default => 0
    end

## Installation

    # gem approach
    gem install sequel-bit-fields

    # bundler approach
    # add this to your Gemfile
    gem 'sequel-bit-fields'

## Side notes

You should always declare the column with a default value of 0. Also NULL should be disabled / not allowed.
Otherwise the plugin will fail hard!

## License
Hereby released under MIT license.

## Authors/Contributors

- BlackLane GmbH
- Sascha Depold ([Twitter](http://twitter.com/sdepold) | [Github](http://github.com/sdepold) | [Website](http://depold.com))
