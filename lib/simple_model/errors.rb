module SimpleModel

  module Errors
    def errors
      @errors ||= ErrorsHash.new
      @errors
    end


    def valid?
      self.errors.clear if errors
      validate
      self.errors.blank? || self.errors.empty?
    end

    def errors?
      !self.errors.nil? && !errors.empty?
    end


    def errors_on(attr)
      self.valid?
      [self.errors.on(attr.to_s)].flatten.compact
    end

    alias :error_on :errors_on

    def errors_to_s
      error_string = ""
      self.errors.full_messages.each do |m|
        error_string << "#{m} "
      end
      error_string
    end

    def validate
      # Override to implement validation
    end

    def errors_for_flash
      error_string = ""
      errors.full_messages.each do |m|
        error_string << "<div>#{m}</div>"
      end
      error_string
    end

    class ErrorsHash
      attr_accessor :errors
      def initialize
        errors
      end

      def errors
        @errors ||= {}
        @errors
      end

      def clear
        self.errors = {}
      end

      def add(attr, message)
        errors[attr.to_s] ||= []
        errors[attr.to_s] << message
      end
      def count
        errors.length
      end
      def empty?
        errors.empty?
      end
      def full_messages
        full_messages = []
        errors.each do |error|
          error[1].each do |message|
            full_messages << "#{error[0].to_s} #{message}"
          end
        end
        full_messages
      end


      def on(attr)
        errors[attr.to_s] if errors[attr.to_s]
      end

      alias :[] :on
    end
  end
end

