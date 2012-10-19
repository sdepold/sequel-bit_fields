require 'sequel'

module Sequel::Plugins
  module BitFields
    def self.configure(model, bit_field_column, bit_fields, options = {})
      bit_fields.each_with_index do |bit_field_name, i|
        index = 2**i

        model.class.instance_eval do
          define_method("#{bit_field_name}_sql") do |value=true|
            "#{bit_field_column} & #{index} #{'!' unless value}= #{index}"
          end
        end

        model.instance_eval do
          define_method("#{bit_field_name}=") do |value|
            self[bit_field_column] = if value
              self[bit_field_column] | (index)
            else
              self[bit_field_column] ^ (index)
            end
          end

          define_method("#{bit_field_name}?") do
            self[bit_field_column] & (index) == (index)
          end
        end
      end
    end
  end
end
