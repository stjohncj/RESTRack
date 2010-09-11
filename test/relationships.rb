require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'pp'

class ResourceController
  def self.has_relationship_to(entity, &get_entity_id_from_relation_id)
    define_method( entity.to_sym,
      Proc.new do |id|
        puts 'in ResourceController method from proc definition id is: ' + id.to_s
        yield id
      end
    )
  end
end

class WizController < ResourceController
  has_relationship_to( :wad ) do |id|
    puts 'in WizController block definition id is: ' + id.to_s
    if id =='1'
      out = 'wad1'
    else
      out = 'nowad'
    end
    out
  end
end

class TestRelationships < Test::Unit::TestCase

  def test_has_relationship_to
    wiz = WizController.new
    puts 'WIZ id_out is ' + wiz.wad('1')
    assert_equal 'wad1', wiz.wad('1')
    puts 'WIZ id_out is ' + wiz.wad('2')
    assert_equal 'nowad', wiz.wad('2')
  end

end