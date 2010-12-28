$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
<<<<<<< HEAD
require 'rspec'
require 'simple_model'
=======
require 'simple_model'
require 'spec'
>>>>>>> d2384f09b6f2ac25fe4e128e1e2477c12b1d5d8b


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

<<<<<<< HEAD
RSpec.configure do |config|
=======
Spec::Runner.configure do |config|
<<<<<<< HEAD
<<<<<<< HEAD

end
=======
=======
>>>>>>> 0b9ea36884e581d9d11b7ba2ce650a5c27dd73be
>>>>>>> d2384f09b6f2ac25fe4e128e1e2477c12b1d5d8b
  
end
>>>>>>> 0b9ea36884e581d9d11b7ba2ce650a5c27dd73be
