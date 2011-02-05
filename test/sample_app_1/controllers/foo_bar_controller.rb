class SampleApp::FooBarController < RESTRack::ResourceController

  pass_through_to( :bata )
  pass_through_to( :bata, :as => :other_bata )

  has_relationship_to( :baz ) do |id|
    if id =='144'
      output = '777'
    else
      output = '666'
    end
    output # You can't "return" from a Proc!  It will do a "return" in the outer method.  Remember a "Proc" is not a Method.
  end

  has_relationship_to( :bat, :as => :slugger ) do |id|
    if id =='144'
      output = '777'
    else
      output = '666'
    end
    output # You can't "return" from a Proc!  It will do a "return" in the outer method.  Remember a "Proc" is not a Method.
  end

  has_relationships_to( :baza, :as => :children ) do |id|
    [1,2,3,4,5,6,7,8,9]
  end
  
  has_defined_relationships_to( :baza, :as => :def ) do |id|
    [1,8,9,17]
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
    if id == '1234567890'
      return { :foo => 'abc', :bar => '123', 'baz' => 456, :more => { :one => 1, :two => [1,2], :three => :deep_fu } }
    end
    if id == '42'
      return {
        :foo => 'abc',
        :bar => 123,
        :baz => {
          'one' => [1],
          'two' => ['1','2'],
          'three' => ['1', 2, {:three => 3}],
          4 => :four
        }
      }
    end
    return { :foo => 'bar', :baz => 123 }
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

  def echo
    return @resource_request.input
  end
  
  def custom_entity(id)
    return id
  end
  
  def custom_collection
    return [1,1,2,3,5,8,13,21,34]
  end

end
