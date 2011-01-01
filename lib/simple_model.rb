module SimpleModel

  autoload :ExtendCore, "simple_model/extend_core"
  autoload :Attributes, "simple_model/attributes"
  begin
    require 'active_model'
  rescue LoadError
    autoload :Errors, "simple_model/errors"
    autoload :Validation, "simple_model/validation"
  end

  class Base
    include SimpleModel::Attributes
    begin
      include ActiveModel::Validations
      include ActiveModel::Conversion
      extend ActiveModel::Naming
    rescue NameError
      include SimpleModel::Errors
      include SimpleModel::Validation
    end    
  end
end
