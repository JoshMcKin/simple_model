module SimpleModel
  module ErrorHelpers

    def errors?
      !self.errors.nil? && !self.errors.empty?
    end

    def errors_for_flash(options={})
      options[:failed_action] ||= "saving"
      options[:div_id] ||= 'errorExplanation'
      options[:div_classes] ||= ''
      error_string = "<div id='#{options[:div_id]}' class='#{options[:div_classes]}'><h2>#{self.errors.count}"
      if self.errors.length > 1
        error_string << " errors"
      else
        error_string << " error"
      end
      error_string << " prevented #{options[:failed_action]}.</h2><ul>"

      self.errors.full_messages.each do |m|
        error_string << "<li>#{m}</li>"
      end
      error_string << "</ul></div>"
      error_string
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
