# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "restrack/version"

Gem::Specification.new do |s|
  s.name        = "restrack"
  s.version     = RESTRack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Chris St. John']
  s.email       = ['chris@stjohnstudios.com']
  s.homepage    = 'http://github.com/stjohncj/RESTRack'
  s.summary     = %q{A lightweight MVC framework developed specifically for JSON (and XML) REST services.}
  s.description = %q{
RESTRack is a Rack-based MVC framework that makes it extremely easy to develop RESTful data services. It is inspired by
Rails, and follows a few of its conventions.  But it has no routes file, routing relationships are done through
supplying custom code blocks to class methods such as "has_relationship_to" or "has_mapped_relationships_to".

RESTRack aims at being lightweight and easy to use.  It will automatically render JSON and XML for the data
structures you return in your actions (any structure parsable by the "json" and
"xml-simple" gems, respectively).

If you supply a view for a controller action, you do that using a builder file.  Builder files are stored in the
view directory grouped by controller name subdirectories (`view/<controller>/<action>.xml.builder`).  XML format
requests will then render the view template with the builder gem, rather than generating XML with XmlSimple.
  }

  s.rubyforge_project = "restrack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'rack'
  s.add_development_dependency 'rack-test'
  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'xml-simple', '>= 1.0.13'
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'mime-types'

end
