require 'simple_model/exceptions'
module SimpleModel
  module Attributes
    include ExtendCore
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods 
    
    def initialize(*attrs)     
      attrs = attrs.extract_options!
      set(attributes_with_defaults.merge(attrs))
    end
    
    # Returns true if attribute has been initialized
    def initialized?(attr)
      attributes.key?(attr.to_sym)
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

    # Accepts a hash where the keys are methods and the values are values to be set.
    # set(:foo => "bar", :dime => 0.1)
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
          :on_set => lambda {|obj,attr| attr},
          :on_get => lambda {|obj,attr| attr},
          :allow_blank => true
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
          unless (self.initialized?(attr) || (!options[:allow_blank] && options.key?(:default) && self.attributes[attr].blank?))
            self.attributes[attr] = fetch_default_value(options[:default])
          end
          options[:on_get].call(self,self.attributes[attr])
        end
        define_method("#{attr.to_s}?") do
          val = self.send(attr)
          val.to_b if val.respond_to?(:to_b)
        end
      end
          
      def define_setter_with_options(attr,options)
        add_defined_attribute(attr,options)
        options = default_attribute_settings.merge(options) if (options[:on_set].blank? || options[:after_set].blank?) 
        define_method("#{attr.to_s}=") do |val|
          val = fetch_default_value(options[:default]) if (options.key?(:default) && val.blank? && !options[:allow_blank?])
          begin   
            val = options[:on_set].call(self,val)
          rescue NoMethodError => e
            raise ArgumentError, "#{val} could not be set for #{attr}: #{e.message}"
          end
          will_change = "#{attr}_will_change!".to_sym
          self.send(will_change) if (self.respond_to?(will_change) && val != self.attributes[attr])          
          self.attributes[attr] = val
          options[:after_set].call(self,val) if options[:after_set] 
        end
      end
    
      AVAILABLE_ATTRIBUTE_METHODS = {
        :has_attribute => {:alias => :has_attributes},
        :has_boolean  => {:cast_to => :to_b, :alias => :has_booleans},
        :has_currency => {:cast_to => :to_d, :alias => :has_currencies},
        :has_date => {:cast_to => :to_date, :alias => :has_dates}, 
        :has_decimal  => {:cast_to => :to_d, :alias => :has_decimals},    
        :has_float => {:cast_to => :to_f, :alias => :has_floats}, 
        :has_int => {:cast_to => :to_i, :alias => :has_ints},
        :has_time => {:cast_to => :to_time, :alias => :has_times}  
      }
      
      AVAILABLE_ATTRIBUTE_METHODS.each do |method,method_options|   
        define_method(method) do |*attributes|
          options = default_attribute_settings.merge(attributes.extract_options!)
          options[:on_set] = lambda {|obj,val| val.send(method_options[:cast_to]) } if method_options[:cast_to]
          create_attribute_methods(attributes,options)
        end
        module_eval("alias #{method_options[:alias]} #{method}")
      end
    end
    
    def self.included(base)
      base.extend(Attributes::ClassMethods)
      base.send(:include, ActiveModel::Dirty) if base.is_a?(Class) # Add Dirty to the class
    end
  end
end