module SimpleModel  
  # Require all that active support we know and love
  require 'active_support/time'
  require 'active_support/core_ext/class/attribute'
  require 'active_support/core_ext/class/attribute_accessors'
  require 'active_support/core_ext/class/delegating_attributes'
  require 'active_support/core_ext/class/attribute'
  require 'active_support/core_ext/array/extract_options'
  require 'active_support/core_ext/hash/deep_merge'
  require 'active_support/core_ext/hash/indifferent_access'
  require 'active_support/core_ext/hash/slice'
  require 'active_support/core_ext/string/behavior'
  require 'active_support/core_ext/kernel/singleton_class'
  require 'active_support/core_ext/module/delegation'
  require 'active_support/core_ext/module/introspection'
  require 'active_support/core_ext/object/duplicable'
  require 'active_support/core_ext/object/blank'

  # == SimpleModel::Base
  #
  # Provides an interface for any class to build tabless models.
  # 
  # Implements Validations and Callsbacks from ActiveModel and attribute datatype specific
  # attribute definition with default options
  # 
  # == SimpleModel Actions:
  # 
  # Model actions provide a tool for making use of Active Model callbacks. Each
  # action creates an instance method representing the action, which calls the 
  # method(s) listed as symbolswhen defining the actions. Model actions also accept 
  # a rollback option, which is called if the action fails. If you plan to 
  # implement SimpleModel's actions make avoid naming you own methods "save", "destory",
  # "create", and "update", as this will override the methods defined by action.
  # 
  # Available Actions:
  #   # save
  #   # update
  #   # create
  #   # destory
  # 
  # ==== Example
  # 
  # class MyModel < SimpleModel::Base
  #   save :my_save, :rollback => :undo_save
  #   update :my_update, :rollback => :undo_update
  #   destroy :my_destory, :rollback => :undo_destory
  # end
  # 
  # A basic SimpleModel implementation might resemble
  # 
  # class MyModel < SimpleModel::Base
  # 
  #   has_integers :first_int, :second_int, :default => 1
  #   has_times :now, :default => :get_now
  #   
  #   save :save_record, :rollback => :rollback
  # 
  #   def save_record
  #     puts "saved"
  #     true
  #   end
  # 
  #   def get_today
  #     Time.now
  #   end
  #   
  #   def rollback
  #     puts "rolled back"
  #   end
  # end
  # 
  # 
  #
 
  class Base
    include SimpleModel::Attributes
    include SimpleModel::ErrorHelpers

    #Use ActiveModel Resources
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    include ActiveModel::Validations::Callbacks
    define_model_callbacks :save, :update, :create, :destroy
     
    has_boolean :saved
    has_boolean :new_record, :default => true
    
    attr_accessor :id

    def persisted?
      saved?
    end
     
    
    def self.save(*methods)
      define_model_action(methods,:save)
    end
    
    def self.create(*methods)
      define_model_action(methods,:create)
    end
    
    def self.update(*methods)
      define_model_action(methods,:update)
    end
      
    #Destroy does not run normal validation by default.
    def self.destroy(*methods)   
      define_model_action(methods,:destroy, {:validate => false})
    end 
    
    private
    
    
    # Skeleton for action instance methods
    def run_model_action(methods,options)
      completed = true
      if !options[:validate] ||
          (options[:validation_methods] && valid_using_other?(options[:validation_methods])) || 
          self.valid?
        
        methods.each do |method|
          ran = self.send(method)
          completed = ran unless ran
        end
        if completed
          self.saved = true
        else
          self.send(options[:rollback]) unless options[:rollback].blank?
        end    
      else 
        completed = false
      end  
      completed
    end
    
    
    # Run supplied methods as valdation. Each method should return a boolean
    # If using this option, to see if errors are present use object_name.errors.blank?,
    # otherwise if you run object_name.valid? you will over write the errors 
    # generated here.
    def valid_using_other?(methods)
      valid = true
      methods.each do |method|
        valid = false unless self.send(method)
      end
      valid
    end
    
    
    # Defines the model action's instantace methods and applied defaults.
    # Defines methods with :validate options as true by default.
    def self.define_model_action(methods,action,default_options={:validate => true})
      default_options.merge!(methods.extract_options!)
      define_method(action) do |opts={}|
        options = default_options.merge(opts)
        self.run_callbacks(action) do  
          run_model_action(methods,options)
        end
      end
    end
  end
end