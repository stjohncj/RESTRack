require 'rubygems'
require 'test/unit'
require 'lib/support'

module RESTRack
  class TestSupport < Test::Unit::TestCase

    def test_decamelize_camelize
      camel = 'FooBarBaz'
      camel2 = RESTRack::Support.camelize( RESTRack::Support.decamelize(camel) )
      puts 'camel: ' + camel
      puts 'camel2: ' + camel2
      assert_equal camel, camel2

      camel = 'FOOBARBaz'
      # Above should be 'FOOBARBaz' always, even if FOO and BAR are separate acronyms
      camel2 = RESTRack::Support.camelize( RESTRack::Support.decamelize(camel) )
      puts 'camel: ' + camel
      puts 'camel2: ' + camel2
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
        #puts RESTRack::CONFIG[:ROOT].to_sym.to_s
        puts RESTRack::CONFIG[:LOG_ROOT].to_sym.to_s
        puts RESTRack::CONFIG[:LOG].to_sym.to_s
        puts RESTRack::CONFIG[:REQUEST_LOG].to_sym.to_s
      end
    end

  end
end
