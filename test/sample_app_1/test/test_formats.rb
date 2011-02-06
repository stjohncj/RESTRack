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
    test_val = XmlSimple.xml_out([1,2,3,4,5,6,7], 'AttrPrefix' => true, 'XmlDeclaration' => true, 'NoIndent' => true)
    assert_equal test_val, output[2]

    env = Rack::MockRequest.env_for('/foo_bar.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = XmlSimple.xml_out([1,2,3,4,5,6,7], 'AttrPrefix' => true, 'XmlDeclaration' => true, 'NoIndent' => true)
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
  
  def test_complex_data_structure_json
    env = Rack::MockRequest.env_for('/foo_bar/1234567890', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "{\"foo\":\"abc\",\"bar\":\"123\",\"baz\":456,\"more\":{\"one\":1,\"two\":[1,2],\"three\":\"deep_fu\"}}"
    assert_equal test_val, output[2]
    
    env = Rack::MockRequest.env_for('/foo_bar/42', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = {
      :foo => 'abc',
      :bar => 123,
      :baz => {
        'one' => [1],
        'two' => ['1','2'],
        'three' => ['1', 2, {:three => 3}],
        4 => :four
      }
    }.to_json
    assert_equal test_val, output[2]
  end
    
  def test_complex_data_structure_xml
    env = Rack::MockRequest.env_for('/foo_bar/1234567890/complex_show_xml_no_builder.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = "<?xml version='1.0' standalone='yes'?>\n<opt><foo>abc</foo><bar>123</bar><baz>456</baz><more><one>1</one><two>1</two><two>2</two><three>deep_fu</three></more></opt>"
    assert_equal test_val, output[2]
    
    env = Rack::MockRequest.env_for('/foo_bar/42/complex_show_xml_no_builder.xml', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    test_val = XmlSimple.xml_out({
      :foo => 'abc',
      :bar => 123,
      :baz => {
        'one' => [1],
        'two' => ['1','2'],
        'three' => ['1', 2, {:three => 3}],
        4 => :four
      }
    }, 'AttrPrefix' => true, 'XmlDeclaration' => true, 'NoIndent' => true)
    assert_equal test_val, output[2]
  end

end
