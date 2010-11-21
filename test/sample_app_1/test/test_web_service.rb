require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','sample_app_1'))

class SampleApp::TestWebService < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new # init logs
  end

  def test_service_name
    env = Rack::MockRequest.env_for('/foo_bar', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    output = ''
    output = @ws.call(env)
    assert_nothing_raised do
      RESTRack::CONFIG[:SERVICE_NAME].to_sym.to_s
    end
  end
end
