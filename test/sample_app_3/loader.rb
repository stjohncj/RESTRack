# for development only
$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'../../lib'))
#####
require 'restrack'

module SampleApp; end
class SampleApp::WebService < RESTRack::WebService; end

RESTRack::CONFIG = RESTRack::load_config(File.join(File.dirname(__FILE__), 'config/constants.yaml'))
RESTRack::CONFIG[:ROOT] = File.dirname(__FILE__)

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

puts "sample_app_3 RESTRack::CONFIG:\n"
config = RESTRack::CONFIG.keys.map {|c| c.to_s }.sort
config.each do |key|
  puts "\t" + key + ' => ' + RESTRack::CONFIG[key.to_sym].to_s
end
puts "\n"
