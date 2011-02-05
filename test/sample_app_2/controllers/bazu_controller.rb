class SampleApp::BazuController < RESTRack::ResourceController

  keyed_with_type Fixnum

  def show(id)
pp id
    return 1 if id == 1
    return 0
  end

end