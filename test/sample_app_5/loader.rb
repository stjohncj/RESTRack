# for development only
$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'../../lib'))
#####
require 'restrack'

module SampleApp5; end
class SampleApp5::WebService < RESTRack::WebService; end

RESTRack::CONFIG = RESTRack::load_config(File.join(File.dirname(__FILE__), 'config/constants.yaml'))
RESTRack::CONFIG[:ROOT] = File.dirname(__FILE__)

require File.join(RESTRack::CONFIG[:ROOT], 'hooks') if File.exists?(File.join(RESTRack::CONFIG[:ROOT], 'hooks.rb'))

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
