# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "decaptcha"

Gem::Specification.new do |s|
  s.name        = "decaptcha"
  s.version     = Decaptcha::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dirty Sánchez"]
  s.email       = ["rmoriz@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/decaptcha"
  s.summary     = %q{helps poor senior data entry specialists in developing countries}
  s.description = %q{helps poor senior data entry specialists in developing countries}

  s.rubyforge_project = "decaptcha"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
