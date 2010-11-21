class SampleApp::FooController < RESTRack::ResourceController

  def show_yaml(id)
    @resource_request.mime_type = RESTRack.mime_type_for('yaml')
    data = { :foo => id, :baz => 'bat' }
  end

  def show_text(id)
    @resource_request.mime_type = RESTRack.mime_type_for('text')
    puts 'test: ' + RESTRack.mime_type_for('text').to_s
    data = "Hello #{id}!"
  end

  def show_image(id)
    @resource_request.mime_type = RESTRack.mime_type_for('png')
    data = File.open(File.join(File.dirname(__FILE__),'../views/alphatest.png'))
  end

end
