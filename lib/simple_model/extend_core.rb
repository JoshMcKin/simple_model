module SimpleModel
  module ToCurrencyS
    def to_currency_s(symbol='$',rnd=2)
      cs = (rnd ? self.round(rnd) : self).abs.to_s
      while cs.index('.') != (cs.length-3)
        cs << '0'
      end
      comma = 6
      while cs.length > (comma)
        cs.insert((cs.length - comma), ",")
        comma += 4
      end
      cs.insert(0,symbol) if symbol
      if self < 0
        cs.insert(0, "-")
      end
      cs
    end
  end

  module ExtendCore
    require 'time'
    require 'date'
    require 'bigdecimal'
    require 'bigdecimal/util'

    Float.class_eval do
      include ToCurrencyS
      # that does not equal 0.0 is true
      def to_b
        !zero?
      end

      # Rounds float to the precision specified
      # 100.5235.round_to #=> 101.0
      # 100.5235.round_to(1) #=> 101.5
      # 100.5235.round_to(3) #=> 101.524
      def round_to(precision=0)
        mulitplier = 10.0 ** (precision)
        (((((self)*mulitplier).round).to_f)/mulitplier)
      end

      
      def to_time
        Time.at(self)
      end
      
      def to_date
        Time.at(self).to_date
      end
    end

    #Extend Ruby String.rb
    String.class_eval do

      US_DATE_REGEX = (/(^[0-9]{1,2}[- \/.][0-9]{1,2}[- \/.][0-9]{4})/).freeze

      JSON_DATE_REGEX = (/^(\/Date\().*(\)\/)$/).freeze

      DIGIT_ONLY_REGEX = (/^+d$/).freeze

      SPLIT_DATE_REGEX = (/\-|\/|\./).freeze

      DATE_TR = ('/\/|\./').freeze

      JSON_DATE_TR = ('/[a-zA-z\(\)\\\/]*/').freeze

      EMPTY_STRING = ''.freeze

      US_DATE_FORMAT = "%m-%d-%Y".freeze

      ISO_DATE_FORMAT = "%Y-%m-%d".freeze

      BOOLEAN_REGEX = (/^(true|t|yes|y|1)$/i).freeze

      # returns boolean value for common boolean string values
      def to_b
        return true if self =~ BOOLEAN_REGEX
        false
      end

      # Takes known US formatted date/time strings (MM/DD/YYYY TIME) and converts
      # them to international format (YYYY/MM/DD TIME). Also cleans up C# JSON
      # Date (really a time integer) value.
      #
      # * safe_date_string("12/31/2010")              # => '2010-12-31'
      # * safe_date_string("12/31/2010T23:30:25")     # => '2010-12-31T23:30:25'
      # * safe_date_string("12/31/2010 23:30:25")     # => '2010-12-31 23:30:25'
      # * safe_date_string("\/Date(1310669017000)\/") # =>
      def safe_datetime_string
        safe_date = nil
        if self =~ US_DATE_REGEX
          safe_date = us_date_to_iso_str
        elsif self =~ JSON_DATE_REGEX
          safe_date = json_date_to_time.to_s
        else
          safe_date = self
        end
        safe_date
      end

      # Use safe_datetime_string help with those pesky US date formats in Ruby 1.9
      # or to change an integer string to date
      def to_date
        return self.to_i.to_date if self =~ DIGIT_ONLY_REGEX
        if self =~ US_DATE_REGEX
          Date.strptime(self.tr(DATE_TR,'-'), US_DATE_FORMAT)
        elsif self =~ JSON_DATE_REGEX
          json_date_to_time.to_date
        else
          Date.strptime(self.tr(DATE_TR,'-'), ISO_DATE_FORMAT)
        end
      end

      # Use safe_datetime_string help with those pesky US date formats in Ruby 1.9
      # or to change an integer string to date
      def to_time
        return self.to_i.to_time if self =~ DIGIT_ONLY_REGEX
        if self =~ US_DATE_REGEX
          Time.parse(us_date_to_iso_str)
        elsif  self =~ JSON_DATE_REGEX
          json_date_to_time
        else
          Time.parse(self)
        end
      end

      alias :core_to_f :to_f

      SCRUB_NUMBER_REGEX = /[^0-9\.\+\-]/.freeze

      # Remove none numeric characters then run default ruby float cast
      def to_f
        gsub(SCRUB_NUMBER_REGEX, EMPTY_STRING).core_to_f
      end

      alias :core_to_d :to_d

      def to_d
        gsub(SCRUB_NUMBER_REGEX, EMPTY_STRING).core_to_d
      end

      private

      def json_date_to_time
        (Time.at(self.tr(JSON_DATE_TR,EMPTY_STRING).to_i / 1000))
      end

      def us_date_to_iso_str
        date_split = split(US_DATE_REGEX)
        time = date_split[2]
        date = date_split[1]
        date_split = date.split(SPLIT_DATE_REGEX)
        "#{date_split[2]}-#{date_split[0]}-#{date_split[1]}#{time}"
      end
    end

    BigDecimal.class_eval do
      include ToCurrencyS

      def to_b
        !zero?
      end
    end

    Fixnum.class_eval do
      include ToCurrencyS

      unless Fixnum.instance_methods.include?(:to_b)
        def to_b
          !zero?
        end
      end

      unless Fixnum.instance_methods.include?(:to_d)
        def to_d
          BigDecimal.new(self)
        end
      end

      unless Fixnum.instance_methods.include?(:to_date)
        def to_date
          Time.at(self).to_date
        end
      end
      unless Fixnum.instance_methods.include?(:to_time)
        def to_time
          Time.at(self)
        end
      end
    end

    NilClass.class_eval do
      unless NilClass.instance_methods.include?(:to_b)
        def to_b
          false
        end
      end
      unless NilClass.instance_methods.include?(:to_d)
        def to_d
          BigDecimal.new('')
        end
      end
    end
    TrueClass.class_eval do
      unless TrueClass.instance_methods.include?(:to_b)
        def to_b
          self
        end
      end
    end
    FalseClass.class_eval do
      unless FalseClass.instance_methods.include?(:to_b)
        def to_b
          self
        end
      end
    end
  end
end
