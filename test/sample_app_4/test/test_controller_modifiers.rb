require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestControllerModifiers < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_pass_through_to
    env = Rack::MockRequest.env_for('/foo/123/bar', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [0,1,2,3].to_json
    assert_equal test_val, output[2][0]


    #"Hello from Bar with id of
  end

end
