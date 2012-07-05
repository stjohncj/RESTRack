require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))

class SampleApp::TestResourceRequest < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new # init logs
  end

## These are the resources which can be accessed from the root of your web service. If left empty, all resources are available at the root.
##:ROOT_RESOURCE_ACCEPT:    []
## These are the resources which cannot be accessed from the root of your web service. Use either this or ROOT_RESOURCE_ACCEPT as a blacklist or whitelist to establish routing (relationships defined in resource controllers define further routing).
#:ROOT_RESOURCE_DENY:      [ 'baz' ]
  def test_root_resource_denied
    env = Rack::MockRequest.env_for('/baz/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_equal 403, output[0]

    env = Rack::MockRequest.env_for('/bat/144', {
      :method => 'GET'
    })
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_not_equal 403, output[0]
  end

  def test_root_resource_accept
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_not_equal 403, output[0]
  end

  def test_default_resource
    # This should be handled by bazu_controller
    env = Rack::MockRequest.env_for('/bad_request', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    # no bad_request method defined/allowed
    assert_equal 405, output[0]

    # This should be handled by bazu_controller
    env = Rack::MockRequest.env_for('/123', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 200, output[0]

    # the following request should hit the default controller's index method (BazuController)
    env = Rack::MockRequest.env_for('', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [
      { :id => 1, :val => 111 },
      { :id => 2, :val => 222 },
      { :id => 3, :val => 333 }
    ].to_json
    assert_equal test_val, output[2][0]
  end
end
