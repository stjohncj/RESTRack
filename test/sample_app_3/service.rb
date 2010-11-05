# TODO: make this work as require 'restrack' when a gem
require File.expand_path(File.join(File.dirname(__FILE__),'../..','restrack'))

module SampleApp; end
class SampleApp::WebService < RESTRack::WebService; end

module RESTRack
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config/constants.yaml'))
end

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

puts "sample_app_3 RESTRack::CONFIG:\n"
config = RESTRack::CONFIG.keys.map {|c| c.to_s }.sort
config.each do |key|
  puts "\t" + key + ' => ' + RESTRack::CONFIG[key.to_sym].to_s
end
puts "\n"