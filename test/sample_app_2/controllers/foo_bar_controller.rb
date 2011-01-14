class SampleApp::FooBarController < RESTRack::ResourceController

  has_direct_relationship_to( :baz ) do |id|
    if id =='144'
      output = '777'
    else
      output = '666'
    end
    output # You can't "return" from a Proc!  It will do a "return" in the outer method.  Remember a "Proc" is not a Method.
  end

  has_direct_relationship_to( :bat, :as => :slugger ) do |id|
    if id =='144'
      output = '777'
    else
      output = '666'
    end
    output # You can't "return" from a Proc!  It will do a "return" in the outer method.  Remember a "Proc" is not a Method.
  end

  has_direct_relationships_to( :baza, :as => :children ) do |id|
    [1,2,3,4,5,6,7,8,9]
  end

  has_mapped_relationships_to( :bazu, :as => :maps ) do |id|
    {
      :first => 1,
      :second => 2,
      :third => 3
    }
  end

  def index
    [1,2,3,4,5,6,7]
  end
  def create
    { :success => true }
  end
  def replace
    { :success => true }
  end
  def drop
    { :success => true }
  end

  def show(id)
    { :foo => 'bar', :baz => 123 }
  end
  def update(id)
    { :success => true }
  end
  def destroy(id)
    { :success => true }
  end
  def add(id)
    { :success => true }
  end

end
