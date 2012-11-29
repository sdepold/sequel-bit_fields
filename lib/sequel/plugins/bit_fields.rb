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

        unless self.respond_to?(:bit_field_indexes_for)
          define_method("bit_field_indexes_for") do |*args|
            if column_name = [*args].first
              hash = {}

              @@bit_fields[column_name].each_with_index do |attribute, i|
                hash[attribute.to_sym] = 2**i
              end

              hash
            else
              raise 'No bit field name was passed!'
            end
          end
        end
      end

      model.instance_eval do
        unless self.respond_to?(:bit_field_values_for)
          # inject the method bit_field_values_for which
          # returns a hash with all the values of the bit_fields
          define_method("bit_field_values_for") do |*args|
            if column_name = [*args].first
              hash = {}

              @@bit_fields[column_name].each do |attribute|
                hash[attribute.to_sym] = self.send("#{attribute}?".to_sym)
              end

              hash
            else
              raise 'No bit field name was passed!'
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

            "`#{self.table_name.to_s}`.`#{bit_field_column}` & #{index} #{'!' unless value}= #{index}"
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
