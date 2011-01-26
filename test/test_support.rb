require 'rubygems'
require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__),'../lib/restrack/support'))

module RESTRack
  class TestSupport < Test::Unit::TestCase

    RESTRack::CONFIG = RESTRack.load_config(File.expand_path(File.join(File.dirname(__FILE__),'../test/sample_app_1/config/constants.yaml')))

    def test_constants
      assert_nothing_raised do
        RESTRack::CONFIG[:LOG].to_sym.to_s
        RESTRack::CONFIG[:LOG_LEVEL].to_sym.to_s
        RESTRack::CONFIG[:REQUEST_LOG].to_sym.to_s
        RESTRack::CONFIG[:REQUEST_LOG_LEVEL].to_sym.to_s
        RESTRack::CONFIG[:DEFAULT_FORMAT].to_sym.to_s
        RESTRack::CONFIG[:DEFAULT_RESOURCE].to_sym.to_s
        assert RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? || RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].class == Array
        assert RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? || RESTRack::CONFIG[:ROOT_RESOURCE_DENY].class == Array
      end
    end

  end
end
