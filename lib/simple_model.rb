module SimpleModel

  #Get those rails goodies
  require 'active_support'
  require 'active_support/i18n'
  require 'active_model'

  # Load as necessary
  autoload :ExtendCore, "simple_model/extend_core"
  autoload :Attributes, "simple_model/attributes"
  autoload :ErrorHelpers, "simple_model/error_helpers"
  autoload :Validation, "simple_model/validation"  
  autoload :Base, "simple_model/base"

  #Railtie
  require 'simple_model/simple_model_railtie.rb' if defined?(Rails)

end
