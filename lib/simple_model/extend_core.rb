module SimpleModel
  module ExtendCore
    require 'time'
    require 'date'
    require 'bigdecimal'
    require 'bigdecimal/util'
  
    Float.class_eval do
    
      # any value greater than 0.0 is true
      def to_b
        self > 0.0
      end
      # Rounds float to the precision specified
      # 100.5235.round_to #=> 101.0
      # 100.5235.round_to(1) #=> 101.5
      # 100.5235.round_to(3) #=> 101.524
      def round_to(precision=0)
        mulitplier = 10.0 ** (precision)
        (((((self)*mulitplier).round).to_f)/mulitplier)
      end

      # Returns a BigDecimal object rounded to the nearest hundredth
      # Why decimal?..because precision matters when dealing with money ;)
      def to_currency
        self.to_d.round(2)
      end

      # Returns a string with representation of currency, rounded to nearest hundredth
      def to_currency_s(symbol="$")
        num = self.round_to(2).to_s
        while num.index('.') != (num.length-3)
          num << '0'
        end
        comma = 6
        while num.length > (comma)
          num.insert((num.length - comma), ",")
          comma += 4
        end
        num.insert(0,symbol)
        num
      end
    end


    #Extend Ruby String.rb
    String.class_eval do

      # returns boolean value for common boolean string values
      def to_b
        ['1',"true", "t"].include?(self)
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
            date_string << "#{time}" unless time.nil? || time.to_s.length == 0
          end
        end
        date_string = date if date_string.length == 0
        date_string
      end
      
      # Use safe_datetime_string help with those pesky US date formats in Ruby 1.9
      def to_date
        Date.parse(safe_datetime_string)
      end

      # Use safe_datetime_string help with those pesky US date formats in Ruby 1.9
      def to_time
        Time.parse(safe_datetime_string)
      end


      alias :old_to_f :to_f

      # Remove none numeric characters then run default ruby float cast
      def to_f
        gsub(/[^0-9\.\+\-]/, '').old_to_f
      end

      # Cleans all none pertinent characters and returns a BigDecimal rounded to nearest hundredth
      # Why decimal?..because precision matters when dealing with money ;)
      def to_currency
        gsub(/[^0-9\.\+\-]/, '').to_d.round(2)
      end

    
      # Parse a full name into it's parts. http://pastie.org/867415
      # Based on :http://artofmission.com/articles/2009/5/31/parse-full-names-with-ruby
      #
      # Options:
      #   +name+
      #   +seperate_middle_name+ defaults to true. if false, will combine middle name into last name.

      def parse_name(seperate_middle_name=true)
        str = self
        if str.include?(',') # Rearrange names formatted as Doe, John C. to John C. Doe
          temp = str.split(',')
          temp << temp[0]
          temp.delete_at(0)
          str = temp.join(" ")

        end
        parts = str.split # First, split the name into an array

        parts.each_with_index do |part, i|
          # If any part is "and", then put together the two parts around it
          # For example, "Mr. and Mrs." or "Mickey and Minnie"
          if part=~/^(and|&)$/i && i > 0
            parts[i-1] = [parts.delete_at(i+1), parts.at(i).downcase, parts.delete_at(i-1)].reverse * " "
          end
        end if self=~/\s(and|&)\s/i # optimize

        { :prefix      => (parts.shift if parts[0]=~/^\w+\./),
          :first_name  =>  parts.shift || "", # if name is "", then atleast first_name should be ""
          :suffix      => (parts.pop   if parts[-1]=~/(\w+\.|[IVXLM]+|[A-Z]+\.|(?i)jr|(?i)sr )$/),
          :last_name   => (seperate_middle_name ? parts.pop : parts.slice!(0..-1) * " "),
          :middle_name => (parts * " " unless parts.empty?) }
      end
    end
    Fixnum.class_eval do

      #Any value greater than 0 is true
      def to_b
        self > 0
      end
      
      def to_d
        BigDecimal.new("#{self}.0")
      end
    end

    NilClass.class_eval do
      def to_b
        false
      end

      def to_d
        BigDecimal.new("0.0")
      end
    end
    TrueClass.class_eval do

      def to_b
        self
      end
    end
    FalseClass.class_eval do
      def to_b
        self
      end
    end
  end
end