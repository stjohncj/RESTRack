class SampleApp::BazuController < RESTRack::ResourceController

  keyed_with_type Fixnum

  def index
    [
      { :id => 1, :val => 111 },
      { :id => 2, :val => 222 },
      { :id => 3, :val => 333 }
    ]
  end

  def show(id)
    return 1 if id == 1
    return 0
  end

end