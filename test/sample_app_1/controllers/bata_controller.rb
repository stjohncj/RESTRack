class SampleApp::BataController < RESTRack::ResourceController

  def show(id)
    return { :BAZ => 'HOLA!' } if id == 777
    return { :BAZ => 'ALOHA!' } if id == '777'
    return { :OTHER => 'YUP' }
  end
  
  def index
    return [1,2,3,4,5]
  end

end