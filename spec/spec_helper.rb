require 'bundler/setup'
Bundler.setup(:default, :development)

require 'sequel-bit-fields'

RSpec.configure do |config|
  DB = Sequel.sqlite

  DB.create_table(:spec) do
    primary_key :id, :auto_increment => true
    Bignum :status_bits, :null => false, :default => 0
  end
end
