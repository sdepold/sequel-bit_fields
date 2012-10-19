require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'sequel-bit-fields'

RSpec.configure do |config|
  DB = Sequel.sqlite

  DB.create_table(:spec) do
    primary_key :id, :auto_increment => true
    Bignum :status_bits, :null => false, :default => 0
  end
end
