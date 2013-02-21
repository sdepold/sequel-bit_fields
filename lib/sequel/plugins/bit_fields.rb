require 'sequel'

module Sequel::Plugins
  module BitFields
    @@bit_fields_for_models = {}

    def self.bit_fields_for_models
      @@bit_fields_for_models
    end

    def self.configure(model, bit_field_column, bit_fields, options = {})
      model.class_eval do
        options[:scope] = bit_field_column        if options[:scope] == true
        options[:scope] = options[:scope].to_sym  if options[:scope].is_a?(String)

        if options[:scope].is_a?(Symbol)
          bit_fields = bit_fields.map { |bit_field| "#{options[:scope]}_#{bit_field}".to_sym }
        end

        @@bit_fields_for_models[model.to_s] ||= {}
        @@bit_fields_for_models[model.to_s][bit_field_column] = bit_fields

        unless respond_to?(:bit_fields)
          define_singleton_method(:bit_fields) do |*args|
            if column_name = [*args].first
              @@bit_fields_for_models[model.to_s][column_name]
            else
              @@bit_fields_for_models[model.to_s]
            end
          end
        end

        unless respond_to?(:bit_field_indexes_for)
          define_singleton_method(:bit_field_indexes_for) do |*args|
            if column_name = [*args].first
              hash = {}

              @@bit_fields_for_models[model.to_s][column_name].each_with_index do |attribute, i|
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
        unless respond_to?(:bit_field_values_for)
          # inject the method bit_field_values_for which
          # returns a hash with all the values of the bit_fields
          define_method("bit_field_values_for") do |*args|
            if column_name = [*args].first
              hash  = {}
              value = [*args][1]

              @@bit_fields_for_models[model.to_s][column_name].each do |attribute|
                hash[attribute.to_sym] = self.send("#{attribute}?".to_sym)
              end

              unless value.nil?
                hash.dup.each do |key, _value|
                  hash.delete(key) unless _value == value
                end
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
            value   = [*args].first
            value   = true if value.nil?
            options = { :table => self.table_name.to_s }.merge([*args][1] || {})

            "`#{options[:table]}`.`#{bit_field_column}` & #{index} #{'!' unless value}= #{index}"
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
            value   = [true, 1, '1', 'true'].include?(value)
            current = self.send("#{bit_field_name}?".to_sym)

            # init the bit_field with 0 if not yet set
            self[bit_field_column] = 0 if self[bit_field_column].nil?

            self[bit_field_column] = if value && !current
              # value is true and current value is false
              self[bit_field_column] | index
            elsif !value && current
              # value is false and current value is true
              self[bit_field_column] ^ index
            else
              # don't do anything
              self[bit_field_column]
            end
          end

          # inject the getter methods
          #
          # example:
          #   model = MyModel.create()
          #   model.finished? # == false
          #
          define_method("#{bit_field_name}?") do
            (self[bit_field_column] || 0) & index == index
          end
        end
      end
    end
  end
end
