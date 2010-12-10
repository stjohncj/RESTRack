class SampleApp::BazuController < RESTRack::ResourceController

  def show(id)
    return 1 if id == 1
    return 0
  end

end