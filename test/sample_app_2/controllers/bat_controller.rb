class SampleApp::BatController < RESTRack::ResourceController

  def show(id)
    return { :WOM => 'BAT!' } if id == 777
    return { :WOM => 'NOBAT!' } if id == '777'
    return { :SUHWING => 'BATTER' }
  end

end