module SimpleModel
  # require all that active support we know and love
  require 'active_support/core_ext/array/extract_options'
  require 'active_support/core_ext/object/blank'
  
  module Attributes
    include ExtendCore

    #Set attribute values to those supplied at initialization
    def initialize(*attrs)
      set_attributes(attrs.extract_options!)
    end

    # Place to store set attributes and their values
    def attributes
      @attributes ||= {}
      @attributes
    end

    def set_attributes(attrs)
      attrs.each do |attr|
        self.send("#{attr[0].to_sym}=",attr[1])
      end
    end
    alias :update_attributes :set_attributes

    def self.included(base)
      base.extend(ClassMethods)
    end
 
    module ClassMethods

      #creates setter and getter datatype special attribute
      def has_attributes(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|

          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val)
            attributes[attr] = val
            val

          end
        end
      end

      # Creates setter and getter methods for boolean attributes
      def has_booleans(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|

          attr_reader attr
          define_reader_with_options(attr,options)  
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_s.to_b)
            attributes[attr] = val
            val
          end

          define_method ("#{attr.to_s}?") do
            send("#{attr.to_s}".to_sym).to_s.to_b
          end
        end
      end
     alias :has_boolean :has_booleans

      # Creates setter and getter methods for integer attributes
      def has_ints(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)

          define_method("#{attr.to_s}=") do |val|             
            instance_variable_set("@#{attr}", val.to_i)
            attributes[attr] = val
            val

          end
        end
      end
      alias :has_int :has_ints

      # Creates setter and getter methods for currency attributes
      # attributes are cast to BigDecimal and rounded to nearest cent
      # Warning, rounding occurs on all sets, so if you need to keep higher prescsion
      # use has_decimals
      def has_currency(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_s.to_currency)
            attributes[attr] = val
            val
          end
        end
      end

      def has_decimals(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", BigDecimal("#{val}"))
            attributes[attr] = val
            val
          end
        end
      end
      alias :has_decimal :has_decimals

      # Creates setter and getter methods for float attributes
      def has_floats(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|

          attr_reader attr
          define_reader_with_options(attr,options)

          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_f)
            attributes[attr] = val
            val

          end
        end
      end
      alias :has_float :has_floats
      # Creates setter and getter methods for date attributes
      def has_dates(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|

          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|   
            val = val.to_date unless val.nil?
            instance_variable_set("@#{attr}", val )
            attributes[attr] = val
            val

          end
        end
      end
      alias :has_date :has_dates
      # Creates setter and getter methods for time attributes
      def has_times(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|
            val = val.to_time unless val.nil?
            instance_variable_set("@#{attr}", val)
            attributes[attr] = val
            val
          end
        end
      end

      def fetch_alias_name(attr)
        alias_name = (attr.to_s << "_old=").to_sym
        self.module_eval("alias #{alias_name} #{attr}")

        alias_name
      end

      # Defines a reader method that returns a default value if current value
      # is nil, if :default is present in the options hash
      def define_reader_with_options(attr,options)
        unless options[:default].blank?
          define_method (attr.to_s) do
            default = options[:default].is_a?(Symbol) ? self.send(options[:default]) : options[:default]
            val = instance_variable_get("@#{attr.to_s}")    
            val = default if val.nil?
            val
          end
        end
      end
    end
  end
end
