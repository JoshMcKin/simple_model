module SimpleModel
  class Config
    DEFAULTS = {
      :initialize_defaults  => false,
      :attributes_store     => (RUBY_VERSION >= "2.2" ? :symbol : :string) # OPTIONS => :string, :symbol, :indifferent
    }.freeze

    ATTRIBUTE_STORES = {
      :symbol => :to_sym,
      :string => :to_s,
      :indifferent => :to_s
    }.freeze

    attr_accessor :initialize_defaults
    alias :initialize_defaults? :initialize_defaults

    attr_accessor :attributes_store

    def initialize
      DEFAULTS.each do |setting, val|
        self.send("#{setting}=", val)
      end
    end

    def attibutes_store_cast
      ATTRIBUTE_STORES[attributes_store]
    end
  end
end
