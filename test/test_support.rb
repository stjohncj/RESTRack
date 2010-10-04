require 'rubygems'
require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__),'..','restrack'))

module RESTRack
  class TestSupport < Test::Unit::TestCase

    def test_decamelize_camelize
      camel = 'FooBarBaz'
      camel2 = RESTRack::Support.camelize( RESTRack::Support.decamelize(camel) )
      assert_equal camel, camel2

      camel = 'FOOBARBaz'
      # Above should be 'FOOBARBaz' always, even if FOO and BAR are separate acronyms
      camel2 = RESTRack::Support.camelize( RESTRack::Support.decamelize(camel) )
      assert_equal camel, camel2
    end

    def test_decamelize
      camel = 'FooBarBaz'
      noncamel = 'foo_bar_baz'
      assert_equal noncamel, RESTRack::Support.decamelize(camel)
      camel = 'FOOBARBaz'
      # Above should be 'FOOBARBaz' always, even if FOO and BAR are separate acronyms
      noncamel = 'FOOBAR_baz'
      assert_equal noncamel, RESTRack::Support.decamelize(camel)
    end

    def test_camelize
      noncamel = 'foo_bar_baz'
      camel = 'FooBarBaz'
      assert_equal camel, RESTRack::Support.camelize(noncamel)
      noncamel = 'FOOBAR_baz'
      # Above should be 'FOOBAR_baz' always, even if FOO and BAR are separate acronyms
      camel = 'FOOBARBaz'
      assert_equal camel, RESTRack::Support.camelize(noncamel)
    end

    def test_constants
      assert_nothing_raised do
        RESTRack::CONFIG[:LOG].to_sym.to_s
        RESTRack::CONFIG[:REQUEST_LOG].to_sym.to_s
        RESTRack::CONFIG[:DEFAULT_FORMAT].to_sym.to_s
        assert RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? or RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].class == Array
        assert RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? or RESTRack::CONFIG[:ROOT_RESOURCE_DENY].class == Array
      end
    end

  end
end
