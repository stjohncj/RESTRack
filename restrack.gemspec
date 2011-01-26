# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "restrack/version"

Gem::Specification.new do |s|
  s.name        = "restrack"
  s.version     = RESTRack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Chris St. John']
  s.email       = ['chris@stjohnstudios.com']
  s.homepage    = 'http://github.com/stjohncj'
  s.summary     = %q{A lightweight MVC framework developed specifically for JSON and XML REST services.}
  s.description = %q{RESTRack is an MVC framework that makes it extremely easy to develop RESTful data services. It is inspired by Rails, and follows some of its conventions, but aims at being lightweight and easy to use.}

  s.rubyforge_project = "restrack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'xml-simple', '>= 1.0.13'
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'mime-types'

end
