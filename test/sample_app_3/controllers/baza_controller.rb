class SampleApp::BazaController < RESTRack::ResourceController

  keyed_with_type Fixnum

  def show(id)
    return { :BAZA => 'YESSIR' } if id == 1
    return { :NOWAY => 'JOSE' } if id == 8
    return { :NOTTODAY => 'JOSEPH' }
  end

end