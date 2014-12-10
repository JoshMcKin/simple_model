module SimpleModel
  module Attributes
    include ExtendCore
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    attr_accessor :attributes
    
    def initialize(*attrs)
      attrs = attrs.extract_options!
      attrs = attributes_with_for_init(attrs)
      attrs = self.class.before_initialize.call(self,attrs) if self.class.before_initialize
      set(attrs)
      self.class.after_initialize.call(self) if self.class.after_initialize
    end

    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end

    # Returns true if attribute has been initialized
    def initialized?(attr)
      self.attributes.key?(attr.to_sym)
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

    def set_attribute(attr,val)
      options = self.class.defined_attributes[attr] || {}
      if allow_attribute_action?(val,options)
        val = fetch_default_value(options[:default]) if (!options[:allow_blank] && options.key?(:default) && val.blank?)
        val = options[:on_set].call(self,val) if options[:on_set] #(!options.key?(:on_set) || (val.blank? && !options[:allow_blank]) )
        self.send("#{attr}_will_change!") if (initialized?(attr) && val != self.attributes[attr])
        self.attributes[attr] = val
        options[:after_set].call(self,val) if options[:after_set]
      end
    end

    def get_attribute(attr)
      val = self.attributes[attr]
      options = self.class.defined_attributes[attr] || {}
      if (options.key?(:default) && (!self.initialized?(attr) || (!options[:allow_blank] && val.blank?)))
        val = self.attributes[attr] = fetch_default_value(options[:default])
      end
      if options[:on_get]
        options[:on_get].call(self,val)
      else
        val
      end
    end

    def get_attribute?(attr)
      val = get_attribute(attr)
      if val.respond_to?(:blank?)
        return !val.blank?
      elsif val.respond_to?(:to_b) 
        return val.to_b
      end
      val
    end

    private

    def attribute_defined?(attr)
      self.class.attribute_defined?(attr)
    end

    def fetch_default_value(arg)
      return self.send(arg) if (arg.is_a?(Symbol) && self.respond_to?(arg))
      arg
    end

    # Returns attribute that have defaults in a hash: {:attribute => "default value"}
    # Checks for alias attributes to ensure they are not overwritten
    def attributes_with_for_init(attrs)
      d = attrs.with_indifferent_access
      self.class.defined_attributes.each do |k,v|
        key = k.to_sym
        if allow_init_default?(d,key,v)
          d[key] = fetch_default_value(v[:default])
        end
      end
      d
    end

    # Only set default if there is a default value, initializing is allow and
    # new attributes do not have a value to set and
    def allow_init_default?(d,k,v)
      (v[:default] && v[:initialize] && (!d.key?(k) && !attributes_have_alias?(d,k)))
    end

    def attributes_have_alias?(attrs,attr)
      !(self.class.alias_attributes.select{ |a, m| (m == attr && attrs.key?(a.to_sym)) }).empty?
    end

    def allow_attribute_action?(val,options)
      return true unless (options[:if] || options[:unless])
      b = true
      opt = options[:if]
      if opt.is_a?(Symbol)
        if opt == :blank
          b = val.blank?
        else
          b = send(opt)
        end
      elsif opt.is_a?(Proc)
        b = opt.call(self,val)
      end
      opt = options[:unless]
      if opt.is_a?(Symbol)
        if opt == :blank
          b = !val.blank?
        else
          b = !send(opt)
        end
      elsif opt.is_a?(Proc)
        b = !opt.call(self,val)
      end
      b
    end

    # Rails 3.2 + required when searching for attributes in from inherited classes/models
    def attribute(name)
      attributes[name.to_sym]
    end

    module ClassMethods
      DEFAULT_ATTRIBUTE_SETTINGS = {:attributes_method => :attributes,
                                    :allow_blank => true,
                                    :initialize => true
                                    }.freeze

      AVAILABLE_ATTRIBUTE_METHODS = {
        :has_attribute => {:alias => :has_attributes},
        :has_boolean  => {:cast_to => :to_b, :alias => :has_booleans},
        :has_currency => {:cast_to => :to_d, :alias => :has_currencies},
        :has_date => {:cast_to => :to_date, :alias => :has_dates} ,
        :has_decimal  => {:cast_to => :to_d, :alias => :has_decimals},
        :has_float => {:cast_to => :to_f, :alias => :has_floats},
        :has_int => {:cast_to => :to_i, :alias => :has_ints},
        :has_time => {:cast_to => :to_time, :alias => :has_times}
      }.freeze

      AVAILABLE_ATTRIBUTE_METHODS.each do |method,method_options|
        define_method(method) do |*attributes|
          options = default_attribute_settings.merge(attributes.extract_options!)
          options[:on_set] = lambda {|obj,val| val.send(method_options[:cast_to]) } if method_options[:cast_to]
          create_attribute_methods(attributes,options)
        end
        module_eval("alias #{method_options[:alias]} #{method}")
      end

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
        nw = self.new()
        nw.attributes = session_hash
        nw.set(nw.send(:attributes_with_for_init,session_hash))
        nw
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
        (self.defined_attributes.member?(attr) || self.superclass.respond_to?(:attribute_defined?) && self.superclass.attribute_defined?(attr))
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
        @default_attribute_settings ||= DEFAULT_ATTRIBUTE_SETTINGS
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
        define_attribute_methods(defined_attributes_keys)
      end

      # We don't want to call define_attribute_methods on methods defined in the parent class
      def defined_attributes_keys
        dak = self.defined_attributes.keys
        dak = dak - self.superclass.defined_attributes.keys if self.superclass.respond_to?(:defined_attributes)
        dak
      end

      # builds the setter and getter methods
      def create_attribute_methods(attributes,options)
        unless attributes.blank?
          attributes.each do |attr|
            define_setter_with_options(attr,options)
            define_reader_with_options(attr,options)
            add_defined_attribute(attr,options)
          end
        end
      end

      def define_reader_with_options(attr,options)
        define_method(attr) do
          get_attribute(attr)
        end
        define_method("#{attr.to_s}?") do
          get_attribute?(attr)
        end
      end

      # Creates setter methods for the provided attributes
      # On set, it will mark the attribute as changed if the attributes has been
      # initialized.
      def define_setter_with_options(attr,options)
        define_method("#{attr.to_s}=") do |val|
          set_attribute(attr,val)
        end
      end

      # Creates alias setter and getter for the supplied attribute using the supplied alias
      # See spec for example.
      def alias_attribute(new_alias,attr)
        
        # get to the base attribute
        while alias_attributes[attr]
          attr = alias_attributes[attr]
        end

        raise UndefinedAttribute, "#{attr} is not a defined attribute so it cannot be aliased" unless defined_attributes[attr]

        alias_attributes[new_alias] = attr

        define_method(new_alias) do
          self.send(attr)
        end
        define_method("#{new_alias}?") do
          self.send("#{attr}?")
        end
        define_method("#{new_alias.to_s}=") do |*args, &block|
          self.send("#{attr.to_s}=",*args, &block)
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
        base.defined_attributes = self.defined_attributes.merge(base.defined_attributes)
        base.alias_attributes = self.alias_attributes.merge(base.alias_attributes)
        super
        # Rails 3.0 Hack
        if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR == 0)
          base.attribute_method_suffix '_changed?', '_change', '_will_change!', '_was'
          base.attribute_method_affix :prefix => 'reset_', :suffix => '!'
        end
      end
    end # end ClassMethods

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
