require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'../lib/restrack'))

module RESTRack
  class TestWebService < Test::Unit::TestCase

    RESTRack::CONFIG = RESTRack.load_config(File.expand_path(File.join(File.dirname(__FILE__),'../test/sample_app_1/config/constants.yaml')))

    def test_call
      env = Rack::MockRequest.env_for('/foo_bar', {
        :method => 'POST',
        :params => %Q|[
          {
            "bar": "baz"
          }
        ]|
      })
      #assert_nothing_raised do
        ws = RESTRack::WebService.new # init logs
        ws.call(env)
      #end
    end

    def test_initialize
      assert_nothing_raised do
        ws = RESTRack::WebService.new
      end
    end

  end # class TestWebService
end # module RESTRack
