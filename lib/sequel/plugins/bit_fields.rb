require 'sequel'

module Sequel::Plugins
  module BitFields
    def self.configure(model, bit_field_column, bit_fields, options = {})
      model.class.instance_eval do
        @@bit_fields ||= {}
        @@bit_fields[bit_field_column] = bit_fields

        unless self.respond_to?(:bit_fields)
          define_method("bit_fields") do |*args|
            if column_name = [*args].first
              @@bit_fields[column_name]
            else
              @@bit_fields
            end
          end
        end
      end

      bit_fields.each_with_index do |bit_field_name, i|
        index = 2**i

        model.class.instance_eval do
          # inject the sql generator methods
          #
          # example:
          #   MyModel.where(MyModel.finished_sql(true)).all
          # and would return
          #   "status_bits & 1 = 1"
          #
          define_method("#{bit_field_name}_sql") do |*args|
            value = [*args].first
            value = true if value.nil?

            "#{bit_field_column} & #{index} #{'!' unless value}= #{index}"
          end
        end

        model.instance_eval do
          # inject the setter methods
          #
          # example:
          #   model = MyModel.create()
          #   model.finished = false
          #
          define_method("#{bit_field_name}=") do |value|
            self[bit_field_column] = if value
              self[bit_field_column] | index
            else
              self[bit_field_column] ^ index
            end
          end

          # inject the getter methods
          #
          # example:
          #   model = MyModel.create()
          #   model.finished? # == false
          #
          define_method("#{bit_field_name}?") do
            self[bit_field_column] & index == index
          end
        end
      end
    end
  end
end
