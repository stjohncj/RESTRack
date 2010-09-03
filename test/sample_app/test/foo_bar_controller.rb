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
    puts 'output from `show` method: ' + output.pretty_inspect
  end

  def test_relation
    env = Rack::MockRequest.env_for('/foo_bar/144/baz', {
      :method => 'GET'
    })
    output = ''
    assert_nothing_raised do
      ws = SampleApp::WebService.new
      output = ws.call(env)
    end
    puts 'output from `show` method: ' + output.pretty_inspect
  end

end