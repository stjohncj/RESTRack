require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestControllerInputs < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_post_no_content_type
    test_val = "random text" # will be converted to json because of default response type
    env = Rack::MockRequest.env_for('/foo_bar/echo', {
      :method => 'POST',
      :input => test_val
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal test_val.to_json, output[2] # will be converted to json because of default response type
  end

  def test_post_json
    test_val = { :echo => 'niner' }.to_json
    env = Rack::MockRequest.env_for('/foo_bar/echo', {
      :method => 'POST',
      :input => test_val,
      'CONTENT_TYPE' => 'application/json'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal test_val, output[2]
  end
  
  def test_post_xml
    test_val = XmlSimple.xml_out({ :echo => 'niner' }, 'AttrPrefix' => true, 'XmlDeclaration' => true)
    env = Rack::MockRequest.env_for('/foo_bar/echo.xml', {
      :method => 'POST',
      :input => test_val,
      'CONTENT_TYPE' => 'application/xml'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal test_val, output[2]
  end
  
  def test_post_text
    test_val = 'OPCODE=PEBKAC'
    env = Rack::MockRequest.env_for('/foo_bar/echo.txt', {
      :method => 'POST',
      :input => test_val,
      'CONTENT_TYPE' => 'text/plain'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal test_val, output[2]
  end
end
