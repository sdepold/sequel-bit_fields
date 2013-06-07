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
MyModel.finished(true).all

# let's find all unfinished instances
MyModel.finished(false)).all

# let's find all the started and the finished instances
MyModel.started.finished.all

# if you need to overwrite the table name:
MyModel.where(MyModel.finished_sql(true, :table => '_my_tmp_model')).all
```

### Get the declared columns

```ruby
MyModel.bit_fields
=begin
{ :status_bits => [ {
  :name => :started,
  :description => "Description for 'started' not available."
}, {
  :name        => :finished,
  :description => "Description for 'finished' not available."
}, {
  :name        => :reviewed,
  :description => "Description for 'reviewed' not available."
} ] }
=end

MyModel.bit_fields( :status_bits )
=begin
[ {
  :name => :started,
  :description => "Description for 'started' not available."
}, {
  :name        => :finished,
  :description => "Description for 'finished' not available."
}, {
  :name        => :reviewed,
  :description => "Description for 'reviewed' not available."
} ]
=end
```

### Get the indexes of the columns

```ruby
MyModel.bit_field_indexes_for( :status_bits )
# => { :started => 1, :finished => 2, :reviewed => 4 }
```

### Get the values of the declared columns:

```ruby
model = MyModel.new
model.finished => true
model.bit_field_values_for( :status_bits )
# => {:started => false, :finished => true, :reviewed => false}

# or with a specific value only:
model.bit_field_values_for( :status_bits, true )
# => { :finished => true }
```

### Get all bit fields of all models, which use the plugin

```ruby
Sequel::Plugins::BitFields.bit_fields_for_models
=begin
{ 'MyModel' => { :status_bits => [ {
    :name => :started,
    :description => "Description for 'started' not available."
  }, {
    :name        => :finished,
    :description => "Description for 'finished' not available."
  }, {
    :name        => :reviewed,
    :description => "Description for 'reviewed' not available."
  } ] }
}
=end
```

### Scoping

As you might find yourself in the situation, where you would like to define
multiple bit fields with the same name, you will notice, that the straightforward
attempt will overwrite the methods of the previously defined bit fields. In order to
fix this, you can pass a `scope` options:

```ruby
class User < Sequel::Model
  plugin :bit_fields, :website_permission_bits,     [ :admin ], :scope => :website
  plugin :bit_fields, :iphone_app_permission_bits,  [ :admin ], :scope => :iphone
  plugin :bit_fields, :android_app_permission_bits, [ :admin ], :scope => :android
end
```

This will change the name of the bit fields:

```ruby
User.new.website_admin?                         # false
User.new.iphone_admin?                          # false
User.new(:android_admin => true).android_admin? # true
```

### Options

Version `1.0.0` introduced the possibility to describe fields. Here is how it looks like:

```ruby
class User < Sequel::Model
  plugin :bit_fields, :some_bits, [{
    :name        => :checked,
    :description => "This bit fields states that the model has been checked by someone."
  }]
end
```

## The table

If you are creating a new model from scratch:

```ruby
DB = Sequel.sqlite

DB.create_table(:my_models) do
  primary_key :id, :auto_increment => true

  # let's use Bignum as it has more space :)
  # set the default to 0 and disallow null values
  Bignum :status_bits, :null => false, :default => 0
end
```

## The migration

If you want to extend an existing model:

```ruby
Sequel.migration do
  change do
    alter_table :users do
      add_column :permission_bits, Bignum, :default => 0, :null => false
    end
  end
end
```

## Installation

```
# gem approach
gem install sequel-bit_fields

# bundler approach
# add this to your Gemfile
gem 'sequel-bit_fields'
```

## Side notes

You should always declare the column with a default value of 0. Also NULL should be disabled / not allowed.
Otherwise the plugin will fail hard!

## License
Hereby released under MIT license.

## Authors/Contributors

- BlackLane GmbH
- [Sascha Depold](http://depold.com) ([Twitter](http://twitter.com/sdepold) | [Github](http://github.com/sdepold))
- jethroo
