require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'service'
require 'pp'

class SampleApp::TestFooBarController < Test::Unit::TestCase

    #env = Rack::MockRequest.env_for('/foo_bar/123', {
    #  :method => 'GET',
    #  :params => %Q|[
    #    {
    #      "bar": "baz"
    #    }
    #  ]|
    #})

  def test_show
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      ws = SampleApp::WebService.new
      output = ws.call(env)
    end
    test_val = { :foo => 'bar', :baz => 123 }.to_json
    assert_equal test_val, output[2]
    puts 'output from `show` method: ' + output.pretty_inspect
  end

  def test_index
    env = Rack::MockRequest.env_for('/foo_bar/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      ws = SampleApp::WebService.new
      output = ws.call(env)
    end
    test_val = [1,2,3,4,5,6,7].to_json
    assert_equal test_val, output[2]
    puts 'output from `index` method: ' + output.pretty_inspect
  end

  def test_relation
    env = Rack::MockRequest.env_for('/foo_bar/144/baz', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      ws = SampleApp::WebService.new
      output = ws.call(env)
      pp ws
    end
    test_val = { :BAZ => 'HOLA!' }.to_json
    assert_equal test_val, output[2]
    puts 'output from baz `show` method: ' + output.pretty_inspect

    env = Rack::MockRequest.env_for('/foo_bar/144/baz/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      ws = SampleApp::WebService.new
      output = ws.call(env)
      pp ws
    end
    test_val = { :BAZ => 'HOLA!' }.to_json
    assert_equal test_val, output[2]
    puts 'output from baz `show` method: ' + output.pretty_inspect
  end

  def test_missing
    env = Rack::MockRequest.env_for('/foo_bar/144/missing', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      ws = SampleApp::WebService.new
      output = ws.call(env)
      pp ws
    end
    puts 'output from `missing` method: ' + output.pretty_inspect
  end

end