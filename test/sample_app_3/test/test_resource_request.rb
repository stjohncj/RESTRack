require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','sample_app_3'))

class SampleApp::TestResourceRequest < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new # init logs
  end

## These are the resources which can be accessed from the root of your web service. If left empty, all resources are available at the root.
#:ROOT_RESOURCE_ACCEPT:    [ 'baz' ]
## These are the resources which cannot be accessed from the root of your web service. Use either this or ROOT_RESOURCE_ACCEPT as a blacklist or whitelist to establish routing (relationships defined in resource controllers define further routing).
##:ROOT_RESOURCE_DENY:      []
  def test_root_resource_denied
    # ROOT_RESOURCE_DENY is not supplied, baz is an allowed resource
    env = Rack::MockRequest.env_for('/baz/144', {
      :method => 'GET'
    })
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_not_equal 403, output[0]
  end

  def test_root_resource_accept
    # this resource is not in ROOT_RESOURCE_ACCEPT, which is set to ['baz']
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_equal 403, output[0]
  end

end
