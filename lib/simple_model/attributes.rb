module SimpleModel
  # require all that active support we know and love
  require 'active_support/core_ext/array/extract_options'
  require 'active_support/core_ext/object/blank'
  
  module Attributes
    include ExtendCore
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
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
    
    # Hook to run method after attribute is converted but before it is set
    def before_attribute_set(method,val)   
    end
    
    alias :update_attributes :set_attributes

    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def fetch_default 
    end
    
 
    module ClassMethods
      
      # Hook to call class method after attribute method definitions
      def after_attribute_definition(attr)  
      end
      
      # Defines a reader method that returns a default value if current value
      # is nil, if :default is present in the options hash
      def define_reader_with_options(attr,options)
        if options.has_key?(:default)
          define_method(attr.to_s) do
            default = (options[:default].is_a?(Symbol) ? self.send(options[:default]) : options[:default])
            val = instance_variable_get("@#{attr.to_s}")    
            val = default unless instance_variable_defined?("@#{attr.to_s}")
            val
          end
        else
          attr_reader attr 
        end
      end
      
      def define_setter(attr,cast_methods)
        define_method("#{attr.to_s}=") do |val|
          val = val.cast_to(cast_methods)
          before_attribute_set(attr,val)
          instance_variable_set("@#{attr}", val)
          attributes[attr] = val
          val
        end
      end
      
      # Builder for attribute methods
      def build_attribute_methods(attr,options={},cast_methods=[])
        define_reader_with_options(attr,options)
        define_setter(attr,cast_methods)
        after_attribute_definition attr
      end
          
      # Left this use a module eval for reference, saw no noticable improvement
      # in speed, so I would rather use code than strings for now
#      def define_setter_with_eval(attr,cast_methods)
#        module_eval <<-STR, __FILE__, __LINE__
#          def #{attr.to_s}=#{attr.to_s}
#              val = #{attr.to_s}.cast_to(#{cast_methods})
#              before_attribute_set(:#{attr.to_s},val)
#              @#{attr.to_s} = val
#              attributes[:#{attr.to_s}] = val
#              val
#          end
#        STR
#      end
      
      #creates setter and getter datatype special attribute
      def has_attributes(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          build_attribute_methods(attr,options)
        end
      end
      alias :has_attribute :has_attributes

      # Creates setter and getter methods for boolean attributes
      def has_booleans(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|                 
          build_attribute_methods(attr,options,[:to_s,:to_b])
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
          build_attribute_methods(attr,options,[:to_i])
        end
      end
      alias :has_int :has_ints

      # Creates setter and getter methods for currency attributes
      # attributes are cast to BigDecimal and rounded to nearest cent
      # #Warning, rounding occurs on all sets, so if you need to keep higher prescsion
      # use has_decimals
      def has_currency(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          build_attribute_methods(attr,options,[:to_s,:to_currency])

        end
      end

      def has_decimals(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          build_attribute_methods(attr,options,[:to_f,:to_d])

        end
      end
      alias :has_decimal :has_decimals

      # Creates setter and getter methods for float attributes
      def has_floats(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          build_attribute_methods(attr,options,[:to_f])

        end
      end
      alias :has_float :has_floats
      
      # Creates setter and getter methods for date attributes
      def has_dates(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          build_attribute_methods(attr,options,[:to_s,:to_date])

        end
      end
      alias :has_date :has_dates
      
      # Creates setter and getter methods for time attributes
      def has_times(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          build_attribute_methods(attr,options,[:to_s,:to_time])

        end
      end 
      alias :has_time :has_times
    end
  end
end
