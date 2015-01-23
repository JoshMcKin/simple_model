module SimpleModel
  module Attributes
    module DefaultValueHelpers

      private
      
      def new_empty_array
        Array.new
      end

      def new_empty_hash
        Hash.new
      end
    end
  end
end
