#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'test/unit'
require 'rack/test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','loader'))

class SampleApp::TestResourceRequest < Test::Unit::TestCase

  def setup
    @ws = SampleApp::WebService.new # init logs
  end

  def test_initialize
    env = Rack::MockRequest.env_for('/foo_bar', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    request = Rack::Request.new(env)
    assert_nothing_raised do
      resource_request = RESTRack::ResourceRequest.new(:request => request)
    end
  end

  def test_root_resource_accept
    # These are the resources which can be accessed from the root of your web service. If left empty, all resources are available at the root.
    #:ROOT_RESOURCE_ACCEPT:    [ 'foo_bar' ]

    RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT] = [ 'foo_bar' ]
    # This should not be allowed because it is not in ROOT_RESOURCE_ACCEPT
    env = Rack::MockRequest.env_for('/bat/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_equal 403, output[0]

    # This should be allowed
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 200, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT] = []
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 200, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT] = nil
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 200, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT] = [ 'foo_bar' ]
  end


  def test_root_resource_denied
    ## These are the resources which cannot be accessed from the root of your web service. Use either this or ROOT_RESOURCE_ACCEPT as a blacklist or whitelist to establish routing (relationships defined in resource controllers define further routing).
    #:ROOT_RESOURCE_DENY:      [ 'baz' ]
    env = Rack::MockRequest.env_for('/baz/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    #test_val = [403, {"Content-Type"=>"text/plain"}, "HTTPStatus::HTTP403Forbidden\nYou are forbidden to access that resource."]
    assert_equal 403, output[0]

    env = Rack::MockRequest.env_for('/bat/144', {
      :method => 'GET'
    })
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_not_equal 200, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_DENY] = []
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 204, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_DENY] = nil
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 204, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_DENY] = ['']
    # it should handle this, although it is incorrect
    env = Rack::MockRequest.env_for('/foo_bar/144', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 204, output[0]

    RESTRack::CONFIG[:ROOT_RESOURCE_DENY] = [ 'baz' ]
  end

  def test_default_resource
    # This should be handled by bazu_controller
    env = Rack::MockRequest.env_for('/', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 403, output[0]
  end

  def test_transcode_defined
    RESTRack::CONFIG.delete(:TRANSCODE)
    RESTRack::CONFIG.delete(:FORCE_ENCODING)
    RESTRack::CONFIG[:TRANSCODE] = 'ISO-8859-1'

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal ["\"ISO-8859-1\""], output[2]

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "€"
        }
      ]|
    })
    output = ''
    #assert_nothing_raised do
      output = @ws.call(env)
    #end
    assert_equal 500, output[0]
  end

  def test_transcode_not_defined
    RESTRack::CONFIG.delete(:TRANSCODE)
    RESTRack::CONFIG.delete(:FORCE_ENCODING)

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal ["\"ASCII-8BIT\""], output[2]

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "€"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 204, output[0]
  end

  def test_force_encoding_defined
    RESTRack::CONFIG.delete(:TRANSCODE)
    RESTRack::CONFIG.delete(:FORCE_ENCODING)
    RESTRack::CONFIG[:FORCE_ENCODING] = 'ISO-8859-1'

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal ["\"ISO-8859-1\""], output[2]

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "€"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 204, output[0]
  end

  def test_force_encoding_not_defined
    RESTRack::CONFIG.delete(:TRANSCODE)
    RESTRack::CONFIG.delete(:FORCE_ENCODING)

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "baz"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal ["\"ASCII-8BIT\""], output[2]

    env = Rack::MockRequest.env_for('/foo_bar/show_encoding', {
      :method => 'POST',
      :params => %Q|[
        {
          "bar": "€"
        }
      ]|
    })
    output = ''
    assert_nothing_raised do
      output = @ws.call(env)
    end
    assert_equal 204, output[0]
  end

end
