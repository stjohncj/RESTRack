class SampleApp::FooController < RESTRack::ResourceController

  pass_through_to( :bar )
  pass_through_to( :baz, :as => :bazzz )

  def show_yaml(id)
    @resource_request.mime_type = RESTRack.mime_type_for('yaml')
    data = { :foo => id, :baz => 'bat' }
  end

  def show_text(id)
    @resource_request.mime_type = RESTRack.mime_type_for('text')
    data = "Hello #{id}!"
  end

  def show_image(id)
    @resource_request.mime_type = RESTRack.mime_type_for('png')
    data = File.read(File.join(File.dirname(__FILE__),'../views/alphatest.png'))
  end

end
