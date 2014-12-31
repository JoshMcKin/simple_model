module SimpleModel
  class Config
    DEFAULTS = {
      :initialize_defaults => true
    }

    attr_accessor :initialize_defaults
    alias :initialize_defaults? :initialize_defaults

    def initialize
      DEFAULTS.each do |setting, val|
        self.send("#{setting}=", val)
      end
    end
  end
end
