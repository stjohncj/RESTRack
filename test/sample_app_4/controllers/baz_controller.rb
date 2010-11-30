class SampleApp::BazController < RESTRack::ResourceController

  def initialize
    @resource_request.mime_type = RESTRack.mime_type_for(:JSON)
  end

  def index
    ['cat', 'dog', 'rat', 'emu']
  end

  def show(id)
    data = { id => "Hello from Bazzz." }
  end

end
