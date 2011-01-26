require 'rubygems'
require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__),'../lib/restrack'))

module RESTRack
  class TestSupport < Test::Unit::TestCase

    def test_constants
      assert_nothing_raised do
        RESTRack::CONFIG[:LOG].to_sym.to_s
        RESTRack::CONFIG[:REQUEST_LOG].to_sym.to_s
        RESTRack::CONFIG[:DEFAULT_FORMAT].to_sym.to_s
        RESTRack::CONFIG[:DEFAULT_RESOURCE].to_sym.to_s
        assert RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? || RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].class == Array
        assert RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? || RESTRack::CONFIG[:ROOT_RESOURCE_DENY].class == Array
      end
    end

  end
end
