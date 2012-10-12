module SimpleModel
  module Attributes
    include ExtendCore
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods 
    
    def initialize(*attrs)     
      attrs = attrs.extract_options!
      set(attributes_with_defaults.merge(attrs))
    end
    
    def attribute_initialized?(attr)
      (attributes.keys.include?(attr.to_s) || attributes.keys.include?(attr.to_sym))
    end
    
    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end
      
    def attributes=attrs
      @attributes = attrs
    end
  
    def get(attr)
      self.send(attr)
    end 
    alias :read :get

    def set(*attrs)
      attrs.extract_options!.each do |attr,val|
        self.send("#{attr.to_s}=",val)
      end
    end
    alias :set_attributes :set
    
    private
    
    def fetch_default_value(arg)
      return self.send(arg) if (arg.is_a?(Symbol) && self.respond_to?(arg))
      arg
    end
    
    # Returns attribute that have defaults in a hash: {:attrbute => "default value"}
    def attributes_with_defaults
      d = {}
      self.class.defined_attributes.each do |k,v|
        d[k] = fetch_default_value(v[:default]) if v[:default]
      end
      d
    end
    
    module ClassMethods   
           
      def defined_attributes
        @defined_attributes ||= {}
      end
      
      def defined_attributes=defined_attributes
        @defined_attributes = defined_attributes
      end
      
      def default_attribute_settings
        @default_attribute_settings ||= {:attributes_method => :attributes,
          :on_set => lambda {|attr| attr},
          :on_get => lambda {|attr,val| 
            val}
        }
      end
      
      def default_attribute_settings=default_attribute_settings
        @default_attribute_settings = default_attribute_settings
      end
    
      def add_defined_attribute(attr,options)
        self.defined_attributes[attr] = options
        define_attribute_methods self.defined_attributes.keys
      end
      
      # builds the setter and getter methods
      def create_attribute_methods(attributes,options)
        unless attributes.blank?  
          attributes.each do |attr|
            define_reader_with_options(attr,options)
            define_setter_with_options(attr,options)
          end
        end
      end
      
      def define_reader_with_options(attr,options)
        add_defined_attribute(attr,options)
        options = default_attribute_settings.merge(options) if options[:on_get].blank?
        define_method(attr) do
          unless self.attribute_initialized?(attr)
            self.attributes[attr] = fetch_default_value(options[:default])
          end
          options[:on_get].call(attr,self.attributes[attr])
        end
        if options[:on_get?]
          define_method("#{attr.to_s}?") do
            options[:on_get?].call(self.send(attr)).to_b
          end
        end
      end
      
      
      def define_setter_with_options(attr,options)
        add_defined_attribute(attr,options)
        options = default_attribute_settings.merge(options) if (options[:on_set].blank? || options[:after_set].blank?) 
        define_method("#{attr.to_s}=") do |val|
          val = options[:on_set].call(val)
          self.send("#{attr}_will_change!".to_sym) if (self.respond_to?("#{attr}_will_change!".to_sym) && val != self.attributes[attr])          
          self.attributes[attr] = val
          options[:after_set].call(attr,val) if options[:after_set] 
        end
      end
    
      def has_attribute(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        create_attribute_methods(attributes,options)
      end
      alias :has_attributes :has_attribute
    
      def has_boolean(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_get?] = options[:on_set] = lambda {|attr| attr.to_b }
        create_attribute_methods(attributes,options)   
      end
      alias :has_booleans :has_boolean
    
      def has_int(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_set] = lambda {|attr| attr.to_i }
        create_attribute_methods(attributes,options)
      end
      alias :has_ints :has_int
    
      def has_decimal(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_set] = lambda {|attr| attr.to_d }
        create_attribute_methods(attributes,options)
      end
      alias :has_decimals :has_decimal
    
      def has_currency(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_set] = lambda {|attr| attr.to_f.to_currency }
        create_attribute_methods(attributes,options)
      end
      alias :has_currencies :has_currency
    
      def has_float(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_set] = lambda {|attr| attr.to_f }
        create_attribute_methods(attributes,options)
      end
      alias :has_floats :has_float
    
      def has_date(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_set] = lambda {|attr| attr.to_date }
        create_attribute_methods(attributes,options)
      end
      alias :has_dates :has_date
    
      def has_time(*attributes)
        options = default_attribute_settings.merge(attributes.extract_options!)
        options[:on_set] = lambda {|attr| attr.to_time }
        create_attribute_methods(attributes,options)
      end
      alias :has_times :has_time
    end
    
    def self.included(base)
      base.extend(Attributes::ClassMethods)
      base.send(:include, ActiveModel::Dirty) if base.is_a?(Class) # Add Dirty to the class
    end
  end
end