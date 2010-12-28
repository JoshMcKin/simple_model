module SimpleModel

  autoload :ExtendCore, "simple_model/extend_core"
  autoload :Attributes, "simple_model/attributes"
  autoload :Errors, "simple_model/errors"
  autoload :Validation, "simple_model/validation"

  class Base
    include SimpleModel::Errors
    include SimpleModel::Attributes
    include SimpleModel::Validation   
  end
end
