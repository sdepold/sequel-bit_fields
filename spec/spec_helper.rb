require 'bundler/setup'
Bundler.setup(:default, :development)

require File.expand_path(File.dirname(__FILE__) + '/../lib/sequel/plugins/bit_fields.rb')

RSpec.configure do |config|
  DB = Sequel.sqlite

  DB.create_table(:spec_models) do
    primary_key :id, :auto_increment => true
    Bignum :status_bits, :null => false, :default => 0
    Bignum :paranoid_bits, :null => false, :default => 0
  end

  DB.create_table(:another_spec_models) do
    primary_key :id, :auto_increment => true
    Bignum :some_bits, :null => false, :default => 0
  end

  DB.create_table(:no_bit_fields_spec_models) do
    primary_key :id, :auto_increment => true
  end
end
