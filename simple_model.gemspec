# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_model/version"


Gem::Specification.new do |s|
  s.name        = "simple_model"
  s.version     = SimpleModel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua T Mckinney"]
  s.email       = ["joshmckin@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Simpifies building tableless models or models backed by webservices}
  s.description = %q{Simpifies building tableless models or models backed by webservices. Create data type specific attributes with default if values. Also, provides a simple error and validation api for non-rails 3 apps.}

  s.add_development_dependency 'rspec', ' 1.3.1'
  s.rubyforge_project = "simple_model"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
