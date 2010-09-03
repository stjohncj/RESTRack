require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'rest_rack'

module RESTRack
  class TestResourceRequest < Test::Unit::TestCase

    def test_locate
      env = Rack::MockRequest.env_for('/foo', {
        :method => 'POST',
        :params => %Q|[
          {
            "bar": "baz"
          }
        ]|
      })
      request = Rack::Request.new(env)

      ws = RESTRack::WebService.new # init logs

      assert_nothing_raised do
        resource_request = RESTRack::ResourceRequest.new(:request => request)
        resource_request.locate
      end
    end

    def test_initialize
      env = Rack::MockRequest.env_for('/foo', {
        :method => 'POST',
        :params => %Q|[
          {
            "bar": "baz"
          }
        ]|
      })
      request = Rack::Request.new(env)

      ws = RESTRack::WebService.new # init logs

      assert_nothing_raised do
        resource_request = RESTRack::ResourceRequest.new(:request => request)
      end
    end

  end
end