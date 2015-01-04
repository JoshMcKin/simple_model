require 'simple_model/config'
module SimpleModel
  module Attributes
    include ExtendCore
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    include ActiveModel::Dirty

    DEFAULT_ATTRIBUTE_SETTINGS = {:attributes_method => :attributes,
                                  :allow_blank => false,
                                  :initialize => true
                                  }.freeze

    AVAILABLE_ATTRIBUTE_METHODS = {
      :has_attribute => {:alias => :has_attributes, :options => {:allow_blank => true}},
      :has_boolean  => {:cast_to => :to_b, :alias => :has_booleans, :options =>  {:allow_blank => true, :boolean => true}},
      :has_currency => {:cast_to => :to_d, :alias => :has_currencies},
      :has_date => {:cast_to => :to_date, :alias => :has_dates} ,
      :has_decimal  => {:cast_to => :to_d, :alias => :has_decimals},
      :has_float => {:cast_to => :to_f, :alias => :has_floats},
      :has_int => {:cast_to => :to_i, :alias => :has_ints},
      :has_time => {:cast_to => :to_time, :alias => :has_times}
    }.freeze

    attr_accessor :attributes

    def initialize(*attrs)
      attrs = attrs.extract_options!
      attrs = self.class.before_initialize.call(self,attrs) if self.class.before_initialize
      set(attrs)
      if config.initialize_defaults?
        defaults = default_attributes_for_init
        set(defaults)
      end
      self.class.after_initialize.call(self) if self.class.after_initialize
    end

    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end

    # Returns true if attribute has been initialized
    def initialized?(attr)
      attributes.key?(attr)
    end

    def get(attr)
      send(attr)
    end
    alias :read :get

    # Accepts a hash where the keys are methods and the values are values to be set.
    # set(:foo => "bar", :dime => 0.1)
    def set(*attrs)
      attrs.extract_options!.each do |attr,val|
        send("#{attr}=",val)
      end
    end
    alias :set_attributes :set

    def set_attribute(attr,val,opts=nil)
      opts ||= fetch_attribute_options(attr)
      if allow_attribute_action?(val,opts)
        allow_blank = opts[:allow_blank]
        val = fetch_default_value(opts[:default]) unless skip_set_default?(attr,opts,val)
        unless (opts[:boolean] ? (!allow_blank && val.blank? && (val != false)) : (!allow_blank && val.blank?))
          val = opts[:on_set].call(self,val) if opts.key?(:on_set)
          send("#{attr}_will_change!") if (initialized?(attr) && val != attributes[attr])
          attributes[attr] = val
          opts[:after_set].call(self,val) if opts[:after_set]
        end
      end
    end

    def get_attribute(attr,opts=nil)
      opts ||= fetch_attribute_options(attr)
      val = attributes[attr]
      val = attributes[attr] ||= fetch_default_value(opts[:default]) unless skip_get_default?(attr,opts,val)
      if opts[:on_get]
        opts[:on_get].call(self,val)
      else
        val
      end
    end

    def fetch_attribute_options(attr)
      self.class.defined_attributes[attr] || {}
    end

    def get_attribute?(attr)
      return false unless val = send(attr)
      if val.respond_to?(:blank?)
        return !val.blank?
      elsif val.respond_to?(:to_b)
        return val.to_b
      end
      !val.nil?
    end

    def attribute_defined?(attr)
      self.class.attribute_defined?(attr)
    end

    # Rails 3.2 + required when searching for attributes in from inherited classes/models
    def attribute(attr)
      get_attribute(attr)
    end

    private

    def skip_get_default?(attr,opts,val)
      (val || !opts.key?(:default) || (opts[:boolean] && (val == false)))
    end

    def skip_set_default?(attr,opts,val)
      return true if (!opts.key?(:default) ||
                      initialized?(attr) ||
                      (opts[:boolean] && (val == false)))
      blnk = val.blank?
      (!blnk || (blnk && opts[:allow_blank]))
    end

    def fetch_default_value(arg)
      return send(arg) if (arg.is_a?(Symbol) && self.respond_to?(arg))
      arg
    end

    # Returns attribute that have defaults in a hash: {:attribute => "default value"}
    # Checks for alias attributes to ensure they are not overwritten
    def default_attributes_for_init
      da = {}
      self.class.defined_attributes.each do |attr,opts|
        if allow_init_default?(attr,opts)
          da[attr] = fetch_default_value(opts[:default])
        end
      end
      da
    end

    # Only set default if there is a default value, initializing is allow and
    # new attributes do not have a value to set and
    def allow_init_default?(attr,opts)
      (opts[:default] && opts[:initialize] && !initialized?(attr) && !initialized_alias?(attr))
    end

    def initialized_alias?(attr)
      base_meth = self.class.alias_attributes.rassoc(attr.to_sym)
      base_meth && attributes.key?(base_meth[0])
      #!(self.class.alias_attributes.select{ |a, m| (m == attr.to_sym && attrs.key?(a)) }).empty?
    end

    def allow_attribute_action?(val,options)
      return true unless (options[:if] || options[:unless])
      b = true
      if opt = options[:if]
        if opt.is_a?(Symbol)
          if opt == :blank
            b = val.blank?
          else
            b = send(opt)
          end
        elsif opt.is_a?(Proc)
          b = opt.call(self,val)
        end
      end
      if opt = options[:unless]
        if opt.is_a?(Symbol)
          if opt == :blank
            b = !val.blank?
          else
            b = !send(opt)
          end
        elsif opt.is_a?(Proc)
          b = !opt.call(self,val)
        end
      end
      b
    end

    def config
      self.class.config
    end

    module ClassMethods
      attr_accessor :config

      AVAILABLE_ATTRIBUTE_METHODS.each do |method,method_options|
        define_method(method) do |*attributes|
          options = attributes.extract_options!
          options = method_options[:options].merge(options) if method_options[:options]
          options = default_attribute_settings.merge(options)
          options[:on_set] = lambda {|obj,val| val.send(method_options[:cast_to]) } if method_options[:cast_to]
          create_attribute_methods(attributes,options)
        end
        module_eval("alias #{method_options[:alias]} #{method}") if method_options[:alias]
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
        nw.set(nw.send(:default_attributes_for_init)) if config.initialize_defaults?
        nw
      end

      def alias_attributes
        @alias_attributes ||= Hash.new
      end

      def alias_attributes=alias_attributes
        @alias_attributes = alias_attributes
      end

      def defined_attributes
        @defined_attributes ||= Hash.new
      end

      def defined_attributes=defined_attributes
        @defined_attributes = defined_attributes
      end

      def attribute_defined?(attr)
        defined_attributes.key?(attr.to_sym)
      end

      # The current intent of the config is allow the managing of features at the global level and overrides options
      # set at attribute definition, which may not be the most flexible and may require re-thinking for future options
      # Options:
      # * config.initialize_defaults default is true, if false prevents attributes with default values from auto-initializing
      def config
        @config ||= SimpleModel::Config.new
      end

      # The default settings for a SimpeModel class
      # Options:
      # * :on_set - accepts a lambda that is run when an attribute is set
      # * :on_get - accepts a lambda that is run when you get/read an attribute
      # * :default - the default value for the attribute, can be a symbol that is sent for a method
      # * :initialize - informations the object whether or not it should initialize the attribute with :default value, defaults to true,
      #                  and is overridden by config.initialzie_defaults
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
        defined_attributes[attr] = options
        @attribute_methods_generated = nil #if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR == 0)
        define_attribute_methods(defined_attributes_keys)
      end

      # We don't want to call define_attribute_methods on methods defined in the parent class
      def defined_attributes_keys
        dak = defined_attributes.keys
        dak = dak - superclass.defined_attributes.keys if superclass.respond_to?(:defined_attributes)
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
          get_attribute(attr,options)
        end
        define_method("#{attr}?") do
          get_attribute?(attr)
        end
      end

      # Creates setter methods for the provided attributes
      # On set, it will mark the attribute as changed if the attributes has been
      # initialized.
      def define_setter_with_options(attr,options)
        define_method("#{attr}=") do |val|
          set_attribute(attr,val,options)
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
          send(attr)
        end
        define_method("#{new_alias}?") do
          send("#{attr}?")
        end
        define_method("#{new_alias}=") do |*args, &block|
          send("#{attr}=",*args, &block)
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
        raise TypeError "before_initialize must be a lambda that accepts the attributes to be initialize" unless before_initialize.is_a?(Proc)
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
        base.defined_attributes = defined_attributes.merge(base.defined_attributes)
        base.alias_attributes = alias_attributes.merge(base.alias_attributes)
        base.config = config.dup
        super
        # Rails 3.0 Hack
        if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR < 1)
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
      base.send(:include, ActiveModel::Validations)
      base.send(:include, ActiveModel::Conversion)
      base.extend ActiveModel::Naming
      base.extend ActiveModel::Callbacks
      base.send(:include, ActiveModel::Validations::Callbacks)

      # Rails 3.0 Hack
      if (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR < 1)
        base.attribute_method_suffix '_changed?', '_change', '_will_change!', '_was'
        base.attribute_method_affix :prefix => 'reset_', :suffix => '!'
      end
    end
  end
end
