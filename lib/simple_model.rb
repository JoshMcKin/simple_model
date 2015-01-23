require 'active_support'
require 'active_support/i18n'
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
require 'active_model'
require "simple_model/extend_core"
require 'simple_model/exceptions'
require 'simple_model/config'
require "simple_model/attributes/default_value_helpers"
require "simple_model/attributes"
require "simple_model/error_helpers"
require "simple_model/validation"
require "simple_model/base"
require 'simple_model/simple_model_railtie.rb' if defined?(Rails)

module SimpleModel
  class << self
    def config
      @config ||= SimpleModel::Config.new
    end
  end
end
