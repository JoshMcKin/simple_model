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

    #User ActiveModel Resources
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  end
end