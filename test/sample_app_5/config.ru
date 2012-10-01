# rackup config.ru
require File.join(File.dirname(__FILE__),'loader')
run SampleApp5::WebService.new
