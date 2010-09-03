class SampleApp::BazController < RESTRack::ResourceController

  def show(id)
    puts 'In SampleApp::BazController instance method: show'
    puts "id: #{id}"
    { :BAZ => 'HOLA!' }
  end

end