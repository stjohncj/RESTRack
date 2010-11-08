# TODO: make this work as require 'restrack' when a gem
require File.expand_path(File.join(File.dirname(__FILE__),'../..','restrack'))
require 'yaml'

module SampleApp; end
class SampleApp::WebService < RESTRack::WebService; end

module RESTRack
  CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config/constants.yaml'))
  if CONFIG[:ROOT_RESOURCE_ACCEPT].is_a?(Array) and CONFIG[:ROOT_RESOURCE_ACCEPT].length == 1 and CONFIG[:ROOT_RESOURCE_ACCEPT][0].lstrip.rstrip == ''
    CONFIG[:ROOT_RESOURCE_ACCEPT] = nil
    WebService.log.warn 'Improper format for RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT], should be nil or empty array not array containing empty string.'
  end
  #if CONFIG[:ROOT_RESOURCE_ACCEPT].is_a?(String) and CONFIG[:ROOT_RESOURCE_ACCEPT].ltrim.rtrim == ''
  #  CONFIG[:ROOT_RESOURCE_ACCEPT] = nil
  #end
end

# Dynamically load all controllers
Find.find(  File.join(File.dirname(__FILE__), 'controllers') ) do |file|
  next if File.extname(file) != '.rb'
  require file
end

if File.directory?( File.join(File.dirname(__FILE__), 'models') )
  # Dynamically load all models
  Find.find(  File.join(File.dirname(__FILE__), 'models') ) do |file|
    next if File.extname(file) != '.rb'
    require file
  end
end

puts "sample_app RESTRack::CONFIG:\n"
config = RESTRack::CONFIG.keys.map {|c| c.to_s }.sort
config.each do |key|
  puts "\t" + key + ' => ' + RESTRack::CONFIG[key.to_sym].to_s
end
puts "\n"
