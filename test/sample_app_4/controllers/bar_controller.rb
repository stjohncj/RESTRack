class SampleApp::BarController < RESTRack::ResourceController

  def index
    [0,1,2,3]
  end

  def show(id)
    data = "Hello from Bar with id of #{id}."
  end

end
