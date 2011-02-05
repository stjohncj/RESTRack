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
    env = Rack::MockRequest.env_for('/foo_bar/144/bata/777', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZ => 'ALOHA!' }.to_json
    assert_equal test_val, output[2]
    
    env = Rack::MockRequest.env_for('/foo_bar/133/bata/abc', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :OTHER => 'YUP' }.to_json
    assert_equal test_val, output[2]
    
    env = Rack::MockRequest.env_for('/foo_bar/144/bata/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [1,2,3,4,5].to_json
    assert_equal test_val, output[2]
    
    env = Rack::MockRequest.env_for('/foo_bar/144/other_bata', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = [1,2,3,4,5].to_json
    assert_equal test_val, output[2]
  end
  
  def test_has_relationship_to
    env = Rack::MockRequest.env_for('/foo_bar/144/baz', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZ => 'ALOHA!' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/baz', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :OTHER => 'YUP' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/144/baz/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZ => 'ALOHA!' }.to_json
    assert_equal test_val, output[2]
    
    #------
    
    env = Rack::MockRequest.env_for('/foo_bar/144/slugger', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :WOM => 'NOBAT!' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/slugger', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :SUHWING => 'BATTER' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/144/slugger/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :WOM => 'NOBAT!' }.to_json
    assert_equal test_val, output[2]
  end
  
  def test_has_relationships_to
    env = Rack::MockRequest.env_for('/foo_bar/133/children/0', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZA => 'YESSIR' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/children/7', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :NOWAY => 'JOSE' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/children/11', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 404, output[0]
  end
  
  # XXX
  def test_has_defined_relationships_to
    # goes to baza
    env = Rack::MockRequest.env_for('/foo_bar/133/def/1', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZA => 'YESSIR' }.to_json
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/def/8', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :NOWAY => 'JOSE' }.to_json
    assert_equal test_val, output[2]
    
    # this should 404
    env = Rack::MockRequest.env_for('/foo_bar/133/def/11', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 404, output[0]
  end
  
  def test_has_mapped_relationships_to
    env = Rack::MockRequest.env_for('/foo_bar/133/maps/first', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = '1'
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/maps/second', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = '0'
    assert_equal test_val, output[2]
  
    env = Rack::MockRequest.env_for('/foo_bar/133/maps/third', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = '0'
    assert_equal test_val, output[2]
  end
  
  def test_keyed_with_type
    # baza controller exercises this option
    env = Rack::MockRequest.env_for('/foo_bar/133/children/0', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZA => 'YESSIR' }.to_json
    assert_equal test_val, output[2]
  end

end
