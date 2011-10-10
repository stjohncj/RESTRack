require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestControllerActions < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  #module HTTPStatus
  #  class HTTP400BadRequest       < Exception; end
  #  class HTTP401Unauthorized     < Exception; end
  #  class HTTP403Forbidden        < Exception; end
  #  class HTTP404ResourceNotFound < Exception; end
  #  class HTTP405MethodNotAllowed < Exception; end
  #  class HTTP409Conflict         < Exception; end
  #  class HTTP410Gone             < Exception; end
  #  class HTTP500ServerError      < Exception; end
  #end

  def test_bad_request
    response_code = 400
    env = Rack::MockRequest.env_for('/errors/bad_request', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
    assert_equal 'tester'.to_json, output[2][0]
  end

  def test_unauthorized
    response_code = 401
    env = Rack::MockRequest.env_for('/errors/unauthorized', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

  def test_forbidden
    response_code = 403
    env = Rack::MockRequest.env_for('/errors/forbidden', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

  def test_resource_not_found
    response_code = 404
    env = Rack::MockRequest.env_for('/errors/resource_not_found', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

  def test_method_not_allowed
    response_code = 405
    env = Rack::MockRequest.env_for('/errors/method_not_allowed', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

  def test_conflict
    response_code = 409
    env = Rack::MockRequest.env_for('/errors/conflict', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

  def test_gone
    response_code = 410
    env = Rack::MockRequest.env_for('/errors/gone', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

  def test_resource_invalid
    response_code = 422
    env = Rack::MockRequest.env_for('/errors/resource_invalid', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
    assert JSON.parse(output[2][0]).has_key?('message')
  end

  def test_resource_invalid_active_record_format
    response_code = 422
    env = Rack::MockRequest.env_for('/errors/resource_invalid_active_resource_format.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
    assert_equal '<?xml version="1.0" encoding="UTF-8"?><errors><error>This is how ActiveResource expects errors to come through.</error><error>It has support for multiple errors.</error></errors>', output[2][0]

    response_code = 422
    env = Rack::MockRequest.env_for('/errors/resource_invalid_active_resource_format', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
    assert_equal 'This is how ActiveResource expects errors to come through.', JSON.parse(output[2][0])[0]
    assert_equal 'It has support for multiple errors.', JSON.parse(output[2][0])[1]
  end

  def test_server_error
    response_code = 500
    # This will/should spam the log
    env = Rack::MockRequest.env_for('/errors/server_error', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal response_code, output[0]
  end

end