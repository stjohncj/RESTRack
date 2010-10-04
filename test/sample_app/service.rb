# TODO: make this work as require 'restrack' when a gem
require File.expand_path(File.join(File.dirname(__FILE__),'../..','restrack'))

module SampleApp; end
class SampleApp::WebService < RESTRack::WebService; end

# Dynamically load all controllers
Find.find(  File.join(File.dirname(__FILE__), 'controllers') ) do |file|
  next if File.extname(file) != '.rb'
  require file
end

# Dynamically load all models
Find.find(  File.join(File.dirname(__FILE__), 'models') ) do |file|
  next if File.extname(file) != '.rb'
  require file
end