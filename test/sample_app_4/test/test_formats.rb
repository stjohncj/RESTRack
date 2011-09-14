require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestFormats < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_yaml
    env = Rack::MockRequest.env_for('/foo/123/show_yaml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 'text/x-yaml', output[1]['Content-Type']
    test_val = YAML.dump( { :foo => '123', :baz => 'bat' } )
    assert_equal test_val, output[2][0]
  end

  def test_text
    env = Rack::MockRequest.env_for('/foo/123/show_text', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 'text/plain', output[1]['Content-Type']
    test_val = 'Hello 123!'
    assert_equal test_val, output[2][0]
  end

  def test_image
    env = Rack::MockRequest.env_for('/foo/123/show_image', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 'image/png', output[1]['Content-Type']
    assert output[2][0].length
  end

end
