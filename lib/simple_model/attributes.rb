module SimpleModel
  module Attributes
    include ExtendCore
 

    #Set attribute values to those supplied at initialization
    def initialize(*attrs)
      attrs.extract_options!.each do |attr|
        self.send(("#{attr[0]}=").to_sym, attr[1])
      end
    end

    ############## Pseudo Rails Methods ###############
    def id
      @id
    end

    def id=(id)
      @id=id
    end

    # Defaults to true so rails will create a "new" form
    # Set to false and rails will produce an "edit" form
    def new_record
      @new_record = true if @new_record.nil?
      @new_record
    end

    def new_record?
      new_record
    end
    
    def new_record=(new_record)
      @new_record = new_record.to_b
    end

    ############### End Pseudo Rails Methods ##############

    # Place to store set attributes and their values
    def attributes
      @attributes ||= {}
      @attributes
    end


    def self.included(base)
      base.extend(ClassMethods)
    end
 
    module ClassMethods
      def has_attributes(*attrs)
        attrs.each do |attr|
          attr_reader attr
  
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val)
            attributes[attr] = val
            val
          end
        end
      end

      # Creates setter and getter methods for boolean attributes
      def has_booleans(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)  
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_s.to_b)
            attributes[attr] = val
            val
          end

          define_method ("#{attr.to_s}?") do
            send("#{attr.to_s}".to_sym).to_s.to_b
          end
        end
      end

      # Creates setter and getter methods for integer attributes
      def has_ints(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_accessor attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|             
            instance_variable_set("@#{attr}", val.to_i)
            attributes[attr] = val
            val
          end
        end
      end

      # Creates setter and getter methods for float attributes
      def has_currency(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_s.to_currency)
            attributes[attr] = val
            val
          end
        end
      end
      # Creates setter and getter methods for float attributes
      def has_floats(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)

          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_f)
            attributes[attr] = val
            val
          end
        end
      end

      # Creates setter and getter methods for date attributes
      def has_dates(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|
            instance_variable_set("@#{attr}", val.to_date)
            attributes[attr] = val
            val
          end
        end
      end

      # Creates setter and getter methods for time attributes
      def has_times(*attrs)
        options = attrs.extract_options!
        attrs.each do |attr|
          attr_reader attr
          define_reader_with_options(attr,options)
          define_method("#{attr.to_s}=") do |val|

            instance_variable_set("@#{attr}", val.to_time)
            attributes[attr] = val
            val
          end
        end
      end

      def fetch_alias_name(attr)
        alias_name = (attr.to_s << "_old=").to_sym
         self.module_eval("alias #{alias_name} #{attr}")
         alias_name
      end

      # Defines a reader method that returns a default value if current value
      # is nil, if :default is present in the options hash
      def define_reader_with_options(attr,options)
        unless options[:default].blank?
          define_method (attr.to_s) do
            val = instance_variable_get("@#{attr.to_s}")
            val = options[:default] if val.nil?
            val
          end
        end
      end
    end
  end
end
