class SampleApp::BazuController < RESTRack::ResourceController

  def show(id)
    return 1 if id == 1
    return 0
  end

  def index
    return [
      { :id => 1, :val => 111 },
      { :id => 2, :val => 222 },
      { :id => 3, :val => 333 }
    ]
  end

end