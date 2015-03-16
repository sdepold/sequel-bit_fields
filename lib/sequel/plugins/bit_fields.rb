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

        bit_fields = bit_fields.dup.map do |bit_field|
          if bit_field.is_a?(Hash)
            raise "Unnamed field: #{bit_field.inspect}" unless bit_field[:name]
            bit_field
          else
            { :name => bit_field }
          end
        end

        if options[:scope].is_a?(Symbol)
          bit_fields = bit_fields.map do |bit_field|
            bit_field.merge(:name => "#{options[:scope]}_#{bit_field[:name]}".to_sym)
          end
        end

        bit_fields = bit_fields.map do |bit_field|
          { :description => "Description for '#{bit_field[:name]}' not available." }.merge(bit_field)
        end

        # at this point, all bit_fields do have the following format:
        # { description => 'something', :name => :something }

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
                hash[attribute[:name].to_sym] = 2**i
              end

              hash
            else
              raise 'No bit field name was passed!'
            end
          end
        end
      end
      
      model.instance_eval do
        # inject convenience method for multiple flag or bit_field assignment
        # overrides default assignment behavior for column_name=
        # example:
        #   model.roles = [:author, :contributor, :reader]
        #   model.roles = 6 # [:contributor, :reader]
        flag_assign = bit_field_column.to_s + '='
        unless respond_to?(flag_assign)
          define_method(flag_assign) do |args|
            args = [*args]
            
            if args.empty?
              self[bit_field_column] = 0
            #argument is an integer
            elsif args.first.is_a?(Fixnum)
              self[bit_field_column] = args.first
            else
              #set each bit_field presented in args to true, others to false
              bit_fields.each do |bit_field|
                self.send("#{bit_field[:name]}=", args.include?(bit_field[:name]))
              end
            end
          end
        end
        
        unless respond_to?(:bit_field_values_for)
          # inject the method bit_field_values_for which
          # returns a hash with all the values of the bit_fields
          define_method("bit_field_values_for") do |*args|
            if column_name = [*args].first
              hash  = {}
              value = [*args][1]

              @@bit_fields_for_models[model.to_s][column_name].each do |attribute|
                hash[attribute[:name].to_sym] = self.send("#{attribute[:name]}?".to_sym)
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

        unless respond_to?(:bit_changed?)
          define_method(:bit_changed?) do |*args|
            if args.size == 1
              bitfield_name = args.first

              # Search for column name and bit
              column_name = nil
              bit         = nil
              @@bit_fields_for_models[model.to_s].each do |_column_name, bitfields|
                bitfields.each_with_index do |bitfield, index|
                  if bitfield[:name] == bitfield_name
                    column_name = _column_name
                    bit         = 1 << index
                    break
                  end
                end
                break if column_name
              end
              raise "Bit field with name `#{bitfield_name}' unknown" unless column_name

              # Check if bit has changed
              return initial_value(column_name) & bit != self[column_name] & bit
            else
              raise 'No bit field name was passed!'
            end
          end
        end
      end

      bit_fields.each_with_index do |bit_field, i|
        bit_field_name = bit_field[:name]
        index          = 2**i

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

            "#{DB.literal(Sequel.qualify(options[:table], bit_field_column))} & #{index} #{'!' unless value}= #{index}"
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

          # inject the dataset methods
          # example:
          #   MyModel.finished(true)
          #   MyModel.where(:foo => "bar").finished
          # and would return a dataset with
          #   "status_bits & 1 = 1"
          #
          dataset_module do
            define_method("#{bit_field_name}") do |*args|
              filter model.send("#{bit_field_name}_sql", *args)
            end
          end
        end
      end
    end
  end
end
