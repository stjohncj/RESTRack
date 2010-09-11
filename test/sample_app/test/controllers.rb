require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'service'
require 'pp'

class SampleApp::TestFooBarController < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_show_root_resource_denied
    env = Rack::MockRequest.env_for('/baz/144', {
      :method => 'GET'
    })
    output = ''
    assert_raise HTTP403Forbidden do
      output = @ws.call(env)
    end

    env = Rack::MockRequest.env_for('/bat/144', {
      :method => 'GET'
    })
    output = ''
    assert_raise HTTP403Forbidden do
      output = @ws.call(env)
    end
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

  def test_delete
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

  def test_destroy
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


  def test_missing
    env = Rack::MockRequest.env_for('/foo_bar/144/missing', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "Method not provided on controller.\nThe resource you requested does not support the request method provided."
    assert_equal test_val, output[2]
  end

  def test_direct_relation
    env = Rack::MockRequest.env_for('/foo_bar/144/baz', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZ => 'HOLA!' }.to_json
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
    test_val = { :BAZ => 'HOLA!' }.to_json
    assert_equal test_val, output[2]
  end

  def test_second_direct_relation
    env = Rack::MockRequest.env_for('/foo_bar/144/slugger', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :WOM => 'BAT!' }.to_json
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
    test_val = { :WOM => 'BAT!' }.to_json
    assert_equal test_val, output[2]
  end

  def test_multiple_relations
    env = Rack::MockRequest.env_for('/foo_bar/133/children/1', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = { :BAZA => 'YESSIR' }.to_json
    assert_equal test_val, output[2]

    env = Rack::MockRequest.env_for('/foo_bar/133/children/8', {
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
    test_val = "Relation entity does not belong to referring resource.\nThe resource you requested could not be found."
    assert_equal test_val, output[2]
  end

  def test_mapped_relations
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

end