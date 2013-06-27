module SimpleModel
  module ErrorHelpers
 
    attr_accessor :errors_count

    def errors?
      !self.errors.blank?
    end


    def errors_for_flash(options={})
      #set defaults and overwrite
      options = {
        :failed_action => "saving",
        :id => 'errorExplanation',
        :classes =>  ''}.merge!(options)
    
      error_list  = ""
      
      # The active_model errors object is not a normal hash and the each method
      # for the active_mode errors object does not perform as expected
      # so make it a plain hash
      {}.merge!(self.errors).each do |error,message|
        error_list << create_error_list(error,message)
      end
      error_string = "<div id='#{options[:id]}' class='#{options[:classes]}'><h2>#{self.errors_count}"
      error_string << " #{puralize_errors_string(self.errors)}"
      error_string << " prevented #{options[:failed_action]}.</h2><ul>"
      error_string << error_list
      error_string << "</ul></div>"
      error_string
    end

    # Allow for nested errors like one might see in nested assets when using
    # accepts_nested_attributes and nested forms
    def create_error_list(key,value)
      error_items = ""
      if value.is_a?(Array)
        value.uniq!
        if value.length == 1
          self.errors_count = (self.errors_count.to_i + 1)
          error_items << "<li>#{key.to_s.titleize} #{value[0]}</li>" 
        else
          error_items << "<li><ul>#{key.to_s.titleize} errors:"
          value.each do |item|
            if item.is_a?(Hash)
              new_value = item.to_a[0]
              error_items << create_error_list(new_value[0],new_value[1])
            else
              self.errors_count = (self.errors_count.to_i + 1)
              error_items << "<li>#{key.to_s.titleize} #{item}</li>"
            end
          end
          error_items << "</ul></li>"
        end
      elsif value.is_a?(Hash)
        error_items << "<li><ul>#{key.to_s.titleize} error:"
        error_items << create_error_list(value[0],value[1])
        error_items << "</ul></li>"
      else
        self.errors_count = (self.errors_count.to_i + 1)
        error_items << "<li>#{key.to_s.titleize} #{value}</li>"
      end
      error_items
    end

    def puralize_errors_string(array)
      array = array.to_a if array.is_a?(ActiveModel::Errors)
      s = "error"
      s << "s" if array.length > 1
      s
    end

  
    def errors_to_s
      error_string = ""
      self.errors.full_messages.each do |m|
        error_string << "#{m} "
      end
      error_string
    end
   
  end
end
