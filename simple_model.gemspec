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
  s.description = %q{Simpifies building tableless models or models backed by webservices. Create data type specific attributes with default if values.}

  s.add_runtime_dependency 'activesupport','~> 3.0.1'
  s.add_runtime_dependency 'activemodel','~> 3.0.1'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'autotest'

  s.rubyforge_project = "simple_model"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
