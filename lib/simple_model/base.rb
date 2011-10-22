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
     
    
    def self.save(*methods)
      define_model_action(methods,:save)
    end
    
    def self.create(*methods)
      define_model_action(methods,:create)
    end
    
    def self.update(*methods)
      define_model_action(methods,:update)
    end
    
    def self.destroy(*methods)
      define_model_action(methods,:destroy)
    end 
    
    private
    
    def run_model_action(methods,options)
      completed = true
      if self.valid?
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
    
    def self.define_model_action(methods,action)
      options = methods.extract_options!
      define_method(action) do
        self.run_callbacks(action) do  
          run_model_action(methods,options)
        end
      end
    end
  end
end