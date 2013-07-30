module SimpleModel
  module Attributes
    include ExtendCore
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    def initialize(*attrs)
      attrs = attrs.extract_options!
      attrs = attributes_with_for_init(attrs)
      attrs = self.class.before_initialize.call(self,attrs) if self.class.before_initialize
      set(attrs)
      self.class.after_initialize.call(self) if self.class.after_initialize
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

    # Returns attribute that have defaults in a hash: {:attribute => "default value"}
    # Checks for alias attributes to ensure they are not overwritten
    def attributes_with_for_init(attrs)
      d = attrs.with_indifferent_access
      self.class.defined_attributes.each do |k,v|
        if allow_set_default?(d,k,v)
          d[k] = fetch_default_value(v[:default])
        end
      end
      d
    end

    def allow_set_default?(d,k,v)
      (v[:default] && v[:initialize] && (d[k].blank? && (self.class.alias_attributes[k].blank? || d.key?(self.class.alias_attributes[k]) && d[self.class.alias_attributes[k]].blank?)))
    end

    private

    def allow_attribute_action?(obj,val,options)
      return true if (options[:if].blank? && options[:unless].blank?)
      b = true
      if options[:if].is_a?(Symbol)
        if options[:if] == :blank
          b =  (b && val.blank?)
        else
          b = (b && send(options[:if]))
        end
      end
      b = (b && options[:if].call(obj,val)) if options[:if].is_a?(Proc)
      if options[:unless].is_a?(Symbol)
        if options[:unless] == :blank
          b = (b && !val.blank?)
        else
          b = (b && !send(options[:unless]))
        end
      end
      b = (b && !options[:unless].call(obj,val)) if options[:unless].is_a?(Proc)
      b
    end

    # Rails 3.2 + required when searching for attributes in from inherited classes/models
    def attribute(name)
      attributes[name.to_sym]
    end

    module ClassMethods
      # Creates a new instance where the attributes store is set to object
      # provided, which allows one to pass a session store hash or any other
      # hash-like object to be used for persistence. Typically used for modeling
      # session stores for authorization or shopping carts
      # EX:
      #     class ApplicationController < ActionController::Base
      #       def session_user
      #         session[:user] ||= {}
      #         @session_user ||= SessionUser.new_with_store(session[:user])
      #       end
      #       helper_method :session_user
      #     end
      #
      def new_with_store(session_hash)
        new = self.new()
        new.attributes = session_hash
        new.set(new.send(:attributes_with_for_init,session_hash))
        new
      end

      def alias_attributes
        @alias_attributes ||= HashWithIndifferentAccess.new
      end

      def alias_attributes=alias_attributes
        @alias_attributes = alias_attributes
      end

      def defined_attributes
        @defined_attributes ||= HashWithIndifferentAccess.new
      end

      def defined_attributes=defined_attributes
        @defined_attributes = defined_attributes
      end

      def attribute_defined?(attr)
        (self.defined_attributes[attr] || self.superclass.respond_to?(:attribute_defined?) && self.superclass.attribute_defined?(attr))
      end

      # The default settings for a SimpeModel class
      # Options:
      # * :on_set - accepts a lambda that is run when an attribute is set
      # * :on_get - accepts a lambda that is run when you get/read an attribute
      # * :default - the default value for the attribute, can be a symbol that is sent for a method
      # * :initialize - informations the object whether or not it should initialize the attribute with :default value, defaults to true
      # ** If :initialize is set to false you must set :allow_blank to false or it will never set the default value
      # * :allow_blank - when set to false, if an attributes value is blank attempts to set the default value, defaults to true
      def default_attribute_settings
        @default_attribute_settings ||= {:attributes_method => :attributes,
                                         :on_set => lambda {|obj,attr| attr},
                                         :on_get => lambda {|obj,attr| attr},
                                         :allow_blank => true,
                                         :initialize => true
                                         }
      end

      def default_attribute_settings=default_attribute_settings
        @default_attribute_settings = default_attribute_settings
      end

      # We want to re-run define_attribute_methods since attributes are not all defined
      # at once, so we must set @attribute_methods_generated to nil to allow the
      # re-run to occur ONLY IN RAILS 3.0.
      def add_defined_attribute(attr,options)
        self.defined_attributes[attr] = options
        @attribute_methods_generated = nil #if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR == 0)
        define_attribute_methods(self.defined_attributes.keys)
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
          val = self.attributes[attr]
          if (options.key?(:default) && (!self.initialized?(attr) || (!options[:allow_blank] && val.blank?)))
            val = self.attributes[attr] = fetch_default_value(options[:default])
          end
          options[:on_get].call(self,val)
        end
        define_method("#{attr.to_s}?") do
          val = self.send(attr)
          if val.respond_to?(:to_b)
            val = val.to_b
          else
            val = !val.blank? if val.respond_to?(:blank?)
          end
          val
        end
      end

      # Creates setter methods for the provided attributes
      # On set, it will mark the attribute as changed if the attributes has been
      # initialized.
      def define_setter_with_options(attr,options)
        add_defined_attribute(attr,options)
        options = default_attribute_settings.merge(options) if (options[:on_set].blank? || options[:after_set].blank?)
        define_method("#{attr.to_s}=") do |val|
          if allow_attribute_action?(self,val,options)
            val = fetch_default_value(options[:default]) if (!options[:allow_blank] && options.key?(:default) && val.blank?)
            val = options[:on_set].call(self,val) unless (val.blank? && !options[:allow_blank] )
            will_change = "#{attr}_will_change!".to_sym
            self.send(will_change) if (initialized?(attr) && val != self.attributes[attr])
            self.attributes[attr] = val
            options[:after_set].call(self,val) if options[:after_set]
          end
        end
      end

      AVAILABLE_ATTRIBUTE_METHODS = {
        :has_attribute => {:alias => :has_attributes},
        :has_boolean  => {:cast_to => :to_b, :alias => :has_booleans},
        :has_currency => {:cast_to => :to_d, :alias => :has_currencies},
        :has_date => {:cast_to => :to_date, :alias => :has_dates} ,
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

      # Creates alias setter and getter for the supplied attribute using the supplied alias
      # See spec for example.
      def alias_attribute(new_alias,attribute)
        alias_attributes[attribute] = new_alias
        define_method(new_alias) do
          self.send(attribute)
        end
        define_method("#{new_alias.to_s}=") do |*args, &block|
          self.send("#{attribute.to_s}=",*args, &block)
        end
      end

      # A hook to perform actions on the pending attributes or the object before
      # the pending attributes have been initialized.
      # Expects an lambda that accept the object, the pending attributes hash and
      # should return a hash to be set
      # EX: lambda {|obj,attrs| attrs.select{|k,v| !v.blank?}}
      def before_initialize
        @before_initialize
      end

      # Expects an lambda that accept the object, the pending attributes hash and
      # should return a hash to be set
      # EX: lambda {|obj,attrs| attrs.select{|k,v| !v.blank?}}
      def before_initialize=before_initialize
        raise TypeError "before_initialize must be a lambda that accepts the attirbutes to be initialize" unless before_initialize.is_a?(Proc)
        @before_initialize = before_initialize
      end

      # A hook to perform actions after all attributes have been initialized
      # Expects an lambda that accept the object and the pending attributes hash
      # EX: lambda {|obj| puts "initialized"}
      def after_initialize
        @after_initialize
      end

      # Expects an lambda that accept the object and the pending attributes hash
      # EX: lambda {|obj| puts "initialized"}
      def after_initialize=after_initialize
        raise TypeError "after_initalize must be a Proc" unless after_initialize.is_a?(Proc)
        @after_initialize = after_initialize
      end

      # Must inherit super's defined_attributes and alias_attributes
      # Rails 3.0 does some weird stuff with ActiveModel::Dirty so we need a
      # hack to keep things working when a class inherits from a super that
      # has ActiveModel::Dirty included
      def inherited(base)
        base.alias_attributes = base.alias_attributes.merge(self.alias_attributes)
        super
        # Rails 3.0 Hack
        if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR == 0)
          base.attribute_method_suffix '_changed?', '_change', '_will_change!', '_was'
          base.attribute_method_affix :prefix => 'reset_', :suffix => '!'
        end
      end
    end

    # Rails 3.0 does some weird stuff with ActiveModel::Dirty so we need a
    # hack to keep things working when a class includes a module that has
    # ActiveModel::Dirty included
    def self.included(base)
      base.extend(Attributes::ClassMethods)
      base.send(:include, ActiveModel::Dirty)
      base.send(:include, ActiveModel::Validations)
      base.send(:include, ActiveModel::Conversion)
      base.extend ActiveModel::Naming
      base.extend ActiveModel::Callbacks
      base.send(:include, ActiveModel::Validations::Callbacks)

      # Rails 3.0 Hack
      if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR == 0)
        base.attribute_method_suffix '_changed?', '_change', '_will_change!', '_was'
        base.attribute_method_affix :prefix => 'reset_', :suffix => '!'
      end
    end
  end
end
