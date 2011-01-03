# To change this template, choose Tools | Templates
# and open the template in the editor.

module ErrorHelpers

  def errors?
    !self.errors.nil? && !self.errors.empty?
  end

  def errors_for_flash
    error_string = "<div id='smErrorExplanation'>#{self.errors.count} errors prevented saving.</div>"
    self.errors.full_messages.each do |m|
      error_string << "<div>#{m}</div>"
    end
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
