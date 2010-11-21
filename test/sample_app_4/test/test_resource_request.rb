require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','sample_app_4'))

class SampleApp::TestResourceRequest < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new # init logs
  end

  def test_root_resource_accept
    #RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT] = ['']
    # it should handle this, although it is incorrect
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 200, output[0]
  end

end
