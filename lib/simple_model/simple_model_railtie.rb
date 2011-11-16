module SimpleModel
  class SimpleModelRailtie  < ::Rails::Railtie
    initializer "simple_model.extend_core" do
      extend SimpleModel::ExtendCore
    end
    if Object.const_defined?(:ActiveRecord)
      initializer "simple_model.ar_error_helper" do
        class ActiveRecord::Base
          include SimpleModel::ErrorHelpers
        end
      end
    end
  end
end