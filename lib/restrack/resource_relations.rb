module RESTRack
  # To extend relationship definition methods to RESTRack::ResourceController
  module ResourceRelations

    # This method allows one to access a related resource, without providing a direct link to specific relation(s).
    def pass_through_to(entity, opts = {})
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do |calling_id| # The calling resource's id will come along for the ride when the new bridging method is called magically from ResourceController#call
          @resource_request.call_controller(entity)
        end
      )
    end

    # This method defines that there is a single link to a member from an entity collection.
    # The second parameter is an options hash to support setting the local name of the relation via ':as => :foo'.
    # The third parameter to the method is a Proc which accepts the calling entity's id and returns the id of the relation to which we're establishing the link.
    # This adds an accessor instance method whose name is the entity's class.
    def has_relationship_to(entity, opts = {}, &get_entity_id_from_relation_id)
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do |calling_id| # The calling resource's id will come along for the ride when the new bridging method is called magically from ResourceController#call
          id = get_entity_id_from_relation_id.call(@id)
          @resource_request.url_chain.unshift(id)
          @resource_request.call_controller(entity)
        end
      )
    end

    # This method defines that there are multiple links to members from an entity collection (an array of entity identifiers).
    # This adds an accessor instance method whose name is the entity's class.
    def has_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do |calling_id| # The parent resource's id will come along for the ride when the new bridging method is called magically from ResourceController#call
          entity_array = get_entity_id_from_relation_id.call(@id)
          begin
            index = @resource_request.url_chain.shift.to_i
          rescue
            raise HTTP400BadRequest, 'You requested an item by index and the index was not a valid number.'
          end
          unless index < entity_array.length
            raise HTTP404ResourceNotFound, 'You requested an item by index and the index was larger than this item\'s list of relations\' length.'
          end
          id = entity_array[index]
          @resource_request.url_chain.unshift(id)
          @resource_request.call_controller(entity)
        end
      )
    end

    # This method defines that there are multiple links to members from an entity collection (an array of entity identifiers).
    # This adds an accessor instance method whose name is the entity's class.
    def has_defined_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do |calling_id| # The parent resource's id will come along for the ride when the new bridging method is called magically from ResourceController#call
          entity_array = get_entity_id_from_relation_id.call(@id)
          id = @resource_request.url_chain.shift
          raise HTTP400BadRequest, 'No ID provided for has_defined_relationships_to routing.' if id.nil?
          id = RESTRack.controller_class_for(entity).format_string_id(id) if id.is_a? String
          unless entity_array.include?( id )
            raise HTTP404ResourceNotFound, 'Relation entity does not belong to referring resource.'
          end
          @resource_request.url_chain.unshift(id)
          @resource_request.call_controller(entity)
        end
      )
    end

    # This method defines that there are mapped links to members from an entity collection (a hash of entity identifiers).
    # This adds an accessor instance method whose name is the entity's class.
    def has_mapped_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do |calling_id| # The parent resource's id will come along for the ride when the new bridging method is called magically from ResourceController#call
          entity_map = get_entity_id_from_relation_id.call(@id)
          key = @resource_request.url_chain.shift
          id = entity_map[key.to_sym]
          @resource_request.url_chain.unshift(id)
          @resource_request.call_controller(entity)
        end
      )
    end

    # Allows decendent controllers to set a data type for the id other than the default.
    def keyed_with_type(klass)
      self.key_type = klass
    end

  end # module ResourceController
end # module RESTRack
