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
  end
end
