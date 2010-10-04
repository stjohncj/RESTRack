require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','service'))

class SampleApp::TestResourceRequest < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new # init logs
  end

  def test_locate
    env = Rack::MockRequest.env_for('/foo_bar', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    request = Rack::Request.new(env)
    assert_nothing_raised do
      resource_request = RESTRack::ResourceRequest.new(:request => request)
      resource_request.locate
    end
  end

  def test_initialize
    env = Rack::MockRequest.env_for('/foo_bar', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    request = Rack::Request.new(env)
    assert_nothing_raised do
      resource_request = RESTRack::ResourceRequest.new(:request => request)
    end
  end

  def test_show_root_resource_denied
    env = Rack::MockRequest.env_for('/baz/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_equal test_val, output

    env = Rack::MockRequest.env_for('/bat/144', {
      :method => 'GET'
    })
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_equal test_val, output
  end

end