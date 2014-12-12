module SimpleModel
  module ToCurrencyS
    def to_currency_s(symbol='$',rnd=2)
      cs = self.round(rnd).abs.to_s
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
        zero?
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
      
      def to_time
        Time.at(self)
      end
      
      def to_date
        Time.at(self).to_date
      end
    end

    #Extend Ruby String.rb
    String.class_eval do

      # returns boolean value for common boolean string values
      def to_b
        return true if self =~ (/^(true|t|yes|y|1)$/i)
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
        if self[0..9].match(/^(0[1-9]|[1-9]|1[012])[- \/.]([1-9]|0[1-9]|[12][0-9]|3[01])[- \/.][0-9][0-9][0-9][0-9]/)
          safe_date = ""
          splt = split(/\-|\/|\./)
          time = ""
          if splt[2].length > 4
            time = splt[2][4..(splt[2].length - 1)]
            splt[2] = splt[2][0..3]
          end
          if splt.length == 3 && splt[2].length == 4
            safe_date << "#{splt[2]}-#{splt[0]}-#{splt[1]}"
            safe_date << "#{time}" unless time.nil? || time.to_s.length == 0
          end
        elsif self.match(/^\/Date\(/)
          safe_date = Time.at(((self.gsub(/(\/Date\()/,"")).gsub(/\)\/$/,"").to_f) / 1000).to_s
        else
          safe_date = self
        end
        safe_date
      end

      # Use safe_datetime_string help with those pesky US date formats in Ruby 1.9
      # or to change an integer string to date
      def to_date
        return safe_datetime_string.to_i.to_date if self.match(/^+d$/)
        Date.parse(safe_datetime_string)
      end

      # Use safe_datetime_string help with those pesky US date formats in Ruby 1.9
      # or to change an integer string to date
      def to_time
        return safe_datetime_string.to_i.to_time if self.match(/^+d$/)
        Time.parse(safe_datetime_string)
      end

      alias :core_to_f :to_f

      # Remove none numeric characters then run default ruby float cast
      def to_f
        gsub(/[^0-9\.\+\-]/, '').core_to_f
      end

      alias :core_to_d :to_d

      def to_d
        gsub(/[^0-9\.\+\-]/, '').core_to_d
      end
      alias :to_currency :to_d

    end

    BigDecimal.class_eval do
      include ToCurrencyS

      def to_b
        zero?
      end
    end
    Fixnum.class_eval do
      include ToCurrencyS

      unless Fixnum.instance_methods.include?(:to_b)
        def to_b
          zero?
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
