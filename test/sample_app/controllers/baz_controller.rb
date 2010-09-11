class SampleApp::BazController < RESTRack::ResourceController

  def show(id)
    return { :BAZ => 'HOLA!' } if id == 777
    return { :BAZ => 'ALOHA!' } if id == '777'
    return { :OTHER => 'YUP' }
  end

end