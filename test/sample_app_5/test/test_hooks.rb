require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp5::TestHooks < Test::Unit::TestCase

  def setup
    @ws = SampleApp5::WebService.new
  end

  def test_pre_processor_enabled
    env = Rack::MockRequest.env_for('/hook/pre_processor', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { 'pre_processor_flag' => true.to_s }.to_json
    assert_equal test_val, output[2][0]
    $post_processor_executed = nil
  end

  def test_pre_processor_disabled
    RESTRack::CONFIG[:PRE_PROCESSOR_DISABLED] = true
    env = Rack::MockRequest.env_for('/hook/pre_processor', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { 'pre_processor_flag' => nil.to_s }.to_json
    assert_equal test_val, output[2][0]
    RESTRack::CONFIG[:PRE_PROCESSOR_DISABLED] = false
$post_processor_executed = nil
  end

  def test_post_processor_enabled
    env = Rack::MockRequest.env_for('/hook/post_processor', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert $post_processor_executed
    $post_processor_executed = nil
  end

  def test_post_processor_disabled
    RESTRack::CONFIG[:POST_PROCESSOR_DISABLED] = true
    env = Rack::MockRequest.env_for('/hook/post_processor', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert !$post_processor_executed
    RESTRack::CONFIG[:POST_PROCESSOR_DISABLED] = false
    $post_processor_executed = nil
  end
  
  def test_post_processor_has_response
    RESTRack::CONFIG[:PRE_PROCESSOR_DISABLED] = false
    RESTRack::CONFIG[:POST_PROCESSOR_DISABLED] = false
    env = Rack::MockRequest.env_for('/hook/post_processor', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert $response.is_a? RESTRack::Response
    $post_processor_executed = nil
  end
  
  def test_post_processor_has_http_status_in_response
    RESTRack::CONFIG[:PRE_PROCESSOR_DISABLED] = false
    RESTRack::CONFIG[:POST_PROCESSOR_DISABLED] = false
    env = Rack::MockRequest.env_for('/hook/post_processor', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal(200, $response.status)
    $post_processor_executed = nil
  end
  
  def test_post_processor_allows_pass_through_of_dynamic_request_attributes
    RESTRack::CONFIG[:PRE_PROCESSOR_DISABLED] = false
    RESTRack::CONFIG[:POST_PROCESSOR_DISABLED] = false
    env = Rack::MockRequest.env_for('/hook/dynamic_request', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal(123456, $response.request.instance_variable_get('@error_code'))
    assert_equal('Invalid password or email address combination', $response.request.instance_variable_get('@error_message'))
    $post_processor_executed = nil
  end
  
end