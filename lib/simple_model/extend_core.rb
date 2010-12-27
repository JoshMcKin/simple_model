module ExtendCore
require 'time'
require 'date'
  Float.class_eval do
    def round_to(precision)
      split = precision.to_s.split(".")
      mulitplier = 10.0 ** (split[1].length)
      (((((self)*mulitplier).round).to_f)/mulitplier)
    end

    # Round to nearest cent
    def to_currency
      round_to(0.01)
    end
  end

  Object.class_eval do
    # Borrowed from Rails activesupport/lib/active_support/core_ext/object/blank.rb
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end


  #Extend Ruby Array.rb
  Array.class_eval do
    # Borrowed from Rails: activesupport/lib/active_support/core_ext/array/extract_options.rb
    # Extracts options from a set of arguments. Removes and returns the last
    # element in the array if it's a hash, otherwise returns a blank hash.
    #
    # def options(*args)
    # args.extract_options!
    # end
    #
    # options(1, 2) # => {}
    # options(1, 2, :a => :b) # => {:a=>:b}
    def extract_options!
      last.is_a?(::Hash) ? pop : {}
    end
  end

  #Extend Ruby String.rb
  String.class_eval do

    # to_b => to_boolean
    def to_b
      ['1',"true", "t"].include?(self)
    end

    alias :to_boolean :to_b

   
    def to_date
      Date.parse(safe_datetime_string)
    end

   
    def to_time
      Time.parse(safe_datetime_string)
    end

    # Takes known US formatted date/time strings (MM/DD/YYYY TIME) and converts
    # them to international format (YYYY/MM/DD TIME)
    #
    # * safe_date_string("12/31/2010")          # => '2010-12-31'
    # * safe_date_string("12/31/2010T23:30:25") # => '2010-12-31T23:30:25'
    # * safe_date_string("12/31/2010 23:30:25") # => '2010-12-31 23:30:25'
    def safe_datetime_string
      date = self
      date_string = ""
      if date[0..9].match(/^(0[1-9]|[1-9]|1[012])[- \/.]([1-9]|0[1-9]|[12][0-9]|3[01])[- \/.][0-9][0-9][0-9][0-9]/)
        if date.include?("/")
          split = date.split("/")
        else
          split = date.split("-")
        end
        time = ""
        if split[2].length > 4
          time = split[2][4..(split[2].length - 1)]
          split[2] = split[2][0..3]
        end
        if split.length == 3 && split[2].length == 4
          date_string << "#{split[2]}-#{split[0]}-#{split[1]}"
          date_string << "#{time}" unless time.blank?
        end
      end
      date_string = date if date_string.blank?
      date_string
    end

    alias :old_to_f :to_f
    # Remove none numeric characters the run default ruby float cast
    def to_f
      gsub(/[^0-9\.\+\-]/, '').old_to_f
    end

    def to_currency
      to_f.to_currency
    end
    
  end
  Fixnum.class_eval do
    #Any value greater than 0 is true
    def to_b
      self > 0
    end
  end   
end
