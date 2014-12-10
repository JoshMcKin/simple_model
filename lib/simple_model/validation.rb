module SimpleModel
  module Validation
    def validates_presence_of(*attr_names)
      options = attr_names.extract_options!
      #set defaults
      options[:message] = "cannot be blank." if options[:message].blank?
      attr_names.each do |attr|
        break if conditional?(options)

        errors.add(attr, options[:message]) if send(attr).blank?
      end
    end

    def validates_format_of(*attr_names)
      options = attr_names.extract_options!
      #set defaults
      options[:message] = "is an invalid format." if options[:message].blank?

      attr_names.each do |attr|
        break if conditional?(options)

        method = send(attr)
        unless method.blank?
          errors.add(attr, options[:message]) unless method.to_s.match(options[:with])
        end
      end
    end

    def validates_length_of(*attr_names)
      options = attr_names.extract_options!

      attr_names.each do |attr|
        break if conditional?(options)

        att_method = send(attr)
        unless att_method.blank?
          errors.add(attr,(options[:message].blank? ? "must equal #{options[:is]} characters in length." : options[:message]))  if options[:is] && att_method.to_s.length != options[:is]
          errors.add(attr,(options[:message].blank? ? "cannot have more than #{options[:maximum]} characters in length." : options[:message]))  if options[:maximum] && att_method.to_s.length > options[:maximum]
          errors.add(attr,(options[:message].blank? ? "cannot have less than #{options[:minimum]} characters in length." : options[:message]))  if options[:minimum] && att_method.to_s.length < options[:minimum]
        end
      end
    end

    def validates_inclusion_of(*attr_names)
      options = attr_names.extract_options!

      first = options[:in].first
      last = options[:in].last
      options[:message] = "must be greater than or equal to #{first} and less than or equal to #{last}" if options[:message].blank?
      attr_names.each do |attr|
        break if conditional?(options)
        attr_method = send(attr).to_f
        unless attr_method.blank?
          errors.add(attr,options[:message]) if attr_method < first  || attr_method > last
        end
      end
    end

    private
    def conditional?(options)
      return true unless ((options[:if].blank? && options[:unless].blank?) ||
      !options[:if].blank? && send(options[:if])) ||
        (!options[:unless].blank? && !send(options[:unless]))
    end
  end
end
