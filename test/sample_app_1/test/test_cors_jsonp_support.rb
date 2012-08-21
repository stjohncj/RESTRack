require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))
require 'pp'

class SampleApp::TestCORSHeaders < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new
  end

  def test_cors_no_origin_header
    RESTRack::CONFIG[:CORS] = {}
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Origin'] = 'http://restrack.me'
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Methods'] = 'POST, GET'
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method     => 'GET'
    })
    output = @ws.call(env)
    expected_status = 403
    expected_headers =  {
      "Content-Type" => "application/json",
      "Access-Control-Allow-Origin"   => "http://restrack.me",
      "Access-Control-Allow-Methods"  => "POST, GET"
    }
    assert_equal expected_status, output[0]
    assert_equal expected_headers, output[1]
  end

  def test_cors_on_allowed_domain
    RESTRack::CONFIG[:CORS] = {}
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Origin'] = 'http://restrack.me'
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Methods'] = 'POST, GET'
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method     => 'GET',
      'HTTP_Origin'    => 'http://restrack.me'
    })
    output = @ws.call(env)
    expected_status = 200
    expected_headers =  {
      "Content-Type" => "application/json",
      "Access-Control-Allow-Origin"   => "http://restrack.me",
      "Access-Control-Allow-Methods"  => "POST, GET"
    }
    expected_body = { :foo => 'bar', :baz => 123 }.to_json
    assert_equal expected_status, output[0]
    assert_equal expected_headers, output[1]
    assert_equal expected_body, output[2][0]
  end

  def test_cors_on_disallowed_domain
    RESTRack::CONFIG[:CORS] = {}
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Origin'] = 'http://restrack.me'
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Methods'] = 'POST, GET'
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method           => 'GET',
      'HTTP_Origin'     => 'http://somehacker.net'
    })
    output = @ws.call(env)
    expected_status = 403
    expected_headers =  {
      "Content-Type" => "application/json",
      "Access-Control-Allow-Origin" => "http://restrack.me",
      "Access-Control-Allow-Methods" => "POST, GET"
    }
    assert_equal expected_status, output[0]
    assert_equal expected_headers, output[1]
  end

  def test_cors_on_disallowed_method
    RESTRack::CONFIG[:CORS] = {}
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Origin'] = 'http://restrack.me'
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Methods'] = 'POST, GET'
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method           => 'PUT',
      'HTTP_Origin'     => 'http://restrack.me'
    })
    output = @ws.call(env)
    expected_status = 403
    expected_headers =  {
      "Content-Type" => "application/json",
      "Access-Control-Allow-Origin" => "http://restrack.me",
      "Access-Control-Allow-Methods" => "POST, GET"
    }
    assert_equal expected_status, output[0]
    assert_equal expected_headers, output[1]
  end

  def test_options_request
    RESTRack::CONFIG[:CORS] = {}
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Origin'] = 'http://restrack.me'
    RESTRack::CONFIG[:CORS]['Access-Control-Allow-Methods'] = 'POST, GET'
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method           => 'OPTIONS',
      'HTTP_Origin'     => 'http://restrack.me'
    })
    output = @ws.call(env)
    expected_status = 200
    expected_headers =  {
      "Content-Type" => "application/json",
      "Access-Control-Allow-Origin" => "http://restrack.me",
      "Access-Control-Allow-Methods" => "POST, GET"
    }
    assert_equal expected_status, output[0]
    assert_equal expected_headers, output[1]
  end

end
