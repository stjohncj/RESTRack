require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestFormats < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_show_builder_xml
    env = Rack::MockRequest.env_for('/foo_bar/144.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><foo>bar</foo><baz>123</baz></data>"
    assert_equal test_val, output[2]
  end

  def test_show_default_xml
    env = Rack::MockRequest.env_for('/foo_bar/index.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><foo>bar</foo><baz>123</baz></data>"
    assert_equal test_val, output[2]

    env = Rack::MockRequest.env_for('/foo_bar.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = XmlSimple.xml_out([1,2,3,4,5,6,7])
    assert_equal test_val, output[2]
  end

  def test_show_json
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
  
  def test_complex_data_structure
    env = Rack::MockRequest.env_for('/foo_bar/1234567890', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "{\"foo\":\"abc\",\"baz\":456,\"bar\":\"123\",\"more\":{\"two\":[1,2],\"three\":\"deep_fu\",\"one\":1}}"
    assert_equal test_val, output[2]
    
    env = Rack::MockRequest.env_for('/foo_bar/1234567890.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><foo>abc</foo><baz>456</baz><bar>123</bar><more><two></data>"
    assert_equal test_val, output[2]
    
    #env = Rack::MockRequest.env_for('/foo_bar/42', {
    #  :method => 'GET'
    #})
    #output = ''
    #assert_nothing_raised do
    #  output = @ws.call(env)
    #end
    ##test_val = {
    ##  :foo => 'abc',
    ##  :bar => 123,
    ##  :baz => {
    ##    'one' => [1],
    ##    'two' => ['1','2'],
    ##    'three' => ['1', 2, {:three => 3}],
    ##    4 => :four
    ##  }
    ##}.to_json
    #assert_equal test_val, output[2]
    #
    #env = Rack::MockRequest.env_for('/foo_bar/42.xml', {
    #  :method => 'GET'
    #})
    #output = ''
    #assert_nothing_raised do
    #  output = @ws.call(env)
    #end
    ##test_val = {
    ##  :foo => 'abc',
    ##  :bar => 123,
    ##  :baz => {
    ##    'one' => [1],
    ##    'two' => ['1','2'],
    ##    'three' => ['1', 2, {:three => 3}],
    ##    4 => :four
    ##  }
    ##}
    #assert_equal test_val, output[2]
  end

end
