#require 'rubygems'
#require 'test/unit'
#require 'rack/test'
#require File.expand_path(File.join(File.dirname(__FILE__),'..','service'))
#require 'pp'
#
#class SampleApp::TestFormats < Test::Unit::TestCase
#
#  def setup
#    @ws = SampleApp::WebService.new
#  end
#
#  def test_show_builder_xml
#    env = Rack::MockRequest.env_for('/foo_bar/144.xml', {
#      :method => 'GET'
#    })
#    output = ''
#    assert_nothing_raised do
#      output = @ws.call(env)
#    end
#    test_val = { :foo => 'bar', :baz => 123 }.to_json
#    assert_equal test_val, output[2]
#  end
#
#  def test_show_default_xml
#    env = Rack::MockRequest.env_for('/baz/144.xml', {
#      :method => 'GET'
#    })
#    output = ''
#    assert_nothing_raised do
#      output = @ws.call(env)
#    end
#    test_val = { :foo => 'bar', :baz => 123 }.to_json
#    assert_equal test_val, output[2]
#  end
#
#  def test_show_json
#    env = Rack::MockRequest.env_for('/foo_bar/144', {
#      :method => 'GET'
#    })
#    output = ''
#    assert_nothing_raised do
#      output = @ws.call(env)
#    end
#    test_val = { :foo => 'bar', :baz => 123 }.to_json
#    assert_equal test_val, output[2]
#  end
#
#  def test_show_bin
#    env = Rack::MockRequest.env_for('/foo_bar/144', {
#      :method => 'GET'
#    })
#    output = ''
#    assert_nothing_raised do
#      output = @ws.call(env)
#    end
#    test_val = { :foo => 'bar', :baz => 123 }.to_json
#    assert_equal test_val, output[2]
#  end
#
#
#  def test_show_png
#    env = Rack::MockRequest.env_for('/foo_bar/144', {
#      :method => 'GET'
#    })
#    output = ''
#    assert_nothing_raised do
#      output = @ws.call(env)
#    end
#    test_val = { :foo => 'bar', :baz => 123 }.to_json
#    assert_equal test_val, output[2]
#  end
#
#end