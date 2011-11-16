module SimpleModel
  module Record
    #Use ActiveModel Resources
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    include ActiveModel::Validations::Callbacks
    include ActiveModel::Dirty
  end
end