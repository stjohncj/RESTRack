require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestControllerActions < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_show
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :foo => 'bar', :baz => 123 }.to_json
    assert_equal test_val, output[2]
  end

  def test_update
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'PUT'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :success => true }.to_json
    assert_equal test_val, output[2]
  end

  def test_add
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'POST'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :success => true }.to_json
    assert_equal test_val, output[2]
  end

  def test_destroy
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'DELETE'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :success => true }.to_json
    assert_equal test_val, output[2]
  end


  def test_index
    env = Rack::MockRequest.env_for('/foo_bar/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [1,2,3,4,5,6,7].to_json
    assert_equal test_val, output[2]
  end

  def test_replace
    env = Rack::MockRequest.env_for('/foo_bar', {
      :method => 'PUT'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :success => true }.to_json
    assert_equal test_val, output[2]
  end

  def test_create
    env = Rack::MockRequest.env_for('/foo_bar/', {
      :method => 'POST'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :success => true }.to_json
    assert_equal test_val, output[2]
  end

  def test_drop
    env = Rack::MockRequest.env_for('/foo_bar', {
      :method => 'DELETE'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :success => true }.to_json
    assert_equal test_val, output[2]
  end

  def test_custom_entity_action
    env = Rack::MockRequest.env_for('/foo_bar/7476/custom_entity', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = '7476'.to_json
    assert_equal test_val, output[2]
  end
  
  def test_custom_collection_action
    env = Rack::MockRequest.env_for('/foo_bar/custom_collection', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [1,1,2,3,5,8,13,21,34].to_json
    assert_equal test_val, output[2]
  end

  def test_missing
    env = Rack::MockRequest.env_for('/foo_bar/144/missing', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 405, output[0]
  end

end
