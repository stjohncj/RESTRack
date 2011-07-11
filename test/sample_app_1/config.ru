# Rails.root/config.ru
require File.join(File.dirname(__FILE__), 'loader')
run SampleApp::WebService.new
