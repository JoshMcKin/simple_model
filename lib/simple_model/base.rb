module SimpleModel
  # require all that active support we know and love
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
     
    # Provides a means of rolling backing actions. 
    # Expects a hash like {:update => :update_rollback, :create => :create_rollback},
    # where :update and :create are the actions that may be preformed, and :update_rollback
    # and :create_rollback are the methods you have defined that perform what is nesseccary
    # to undo whatever may have been done.
    def self.rollbacks(methods={})    
      define_method("rollback(action)") do
        completed = true
        methods.each do |method, action|      
          rolled_back = self.send(action) if self.respond_to(action)
          completed = rolled_back unless rolled_back                   
        end
        completed
      end
    end
    
    def self.save(*methods)
      self.define_action(methods,:save)
    end
    
    def self.create(*methods)
      self.define_action(methods,:create)
    end
    
    def self.update(*methods)
      self.define_action(methods,:update)
    end
    
    def self.destroy(*methods)
      self.define_action(methods,:destroy)
    end 
    
    private
    
    def run_action(methods,action)
      completed = true
      if self.valid?
        if block_given?
          completed = yield 
        else
          methods.each do |method|
            ran = self.send(method)
            completed = ran unless ran
          end
        end       
        if completed
          self.saved = true
        else
          self.rollback(action) unless completed
        end    
      else 
        completed = false
      end  
      completed
    end
    
    def self.define_action(methods,action)
      define_method(action) do
        self.run_callbacks(action) do  
          run_action(methods,action)
        end
      end
    end
  end
end