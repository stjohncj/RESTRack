class SampleApp::FooBarController < RESTRack::ResourceController

  has_relationship_from :baz, &get_baz_id_from_foo_bar_id

  def get_baz_id_from_foo_bar_id(id)
    '777'
  end

  def index
    puts 'In SampleApp::FooBarController class method: index'
    [1,2,3,4,5,6,7]
  end
  def create
    puts 'In SampleApp::FooBarController class method: create'
    { :success => true }
  end
  def replace
    puts 'In SampleApp::FooBarController instance method: replace'
    { :success => true }
  end
  def destroy
    puts 'In SampleApp::FooBarController instance method: destroy'
    { :success => true }
  end

  def show(id)
    puts 'In SampleApp::FooBarController instance method: show'
    puts "id: #{id}"
    { :foo => 'bar', :baz => 123 }
  end
  def update(id)
    puts 'In SampleApp::FooBarController instance method: update'
    puts "id: #{id}"
    { :success => true }
  end
  def delete(id)
    puts 'In SampleApp::FooBarController instance method: delete'
    puts "id: #{id}"
    { :success => true }
  end
  def add(id)
    puts 'In SampleApp::FooBarController instance method: add'
    puts "id: #{id}"
    { :success => true }
  end

end