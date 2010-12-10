module RESTRack
  class ResourceController
    attr_reader :input, :output

    def self.__init(resource_request)
      # Base initialization method for resources and storage of request input
      # This method should not be overriden in decendent classes.
      __self = self.new
      return __self.__init(resource_request)
    end
    def __init(resource_request)
      @resource_request = resource_request
      setup_action
      self
    end

    def call
      # Call the controller's action and return it in the proper format.
      args = []
      args << @resource_request.id unless @resource_request.id.blank?
      package( self.send(@resource_request.action.to_sym, *args) )
    end

    #                    HTTP Verb: |    GET    |   PUT     |   POST    |   DELETE
    # Collection URI (/widgets/):   |   index   |   replace |   create  |   destroy
    # Element URI   (/widgets/42):  |   show    |   update  |   add     |   delete

    #def index;       end
    #def replace;     end
    #def create;      end
    #def destroy;     end
    #def show(id);    end
    #def update(id);  end
    #def add(id);     end
    #def delete(id);  end

    def method_missing(method_sym, *arguments, &block)
      raise HTTP405MethodNotAllowed, 'Method not provided on controller.'
    end

    protected # all internal methods are protected rather than private so that calling methods *could* be overriden if necessary.
    def self.has_relationship_to(entity, opts = {})
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do
          @resource_request.id, @resource_request.action = nil, nil
          ( @resource_request.id, @resource_request.action, @resource_request.path_stack ) = @resource_request.path_stack.split('/', 3) unless @resource_request.path_stack.blank?
          if [ :index, :replace, :create, :destroy ].include? @resource_request.id
            @resource_request.action = @resource_request.id
            @resource_request.id = nil
          end
          format_id
          self.call_relation(entity)
        end
      )
    end

    def self.has_direct_relationship_to(entity, opts = {}, &get_entity_id_from_relation_id)
      # This method defines that there is a single link to a member from an entity collection.
      # The second parameter is an options hash to support setting the local name of the relation via ':as => :foo'.
      # The third parameter to the method is a Proc which accepts the calling entity's id and returns the id of the relation to which we're establishing the link.
      # This adds an accessor instance method whose name is the entity's class.
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do
          @resource_request.id = get_entity_id_from_relation_id.call(@resource_request.id)
          @resource_request.action = nil
          ( @resource_request.action, @resource_request.path_stack ) = @resource_request.path_stack.split('/', 3) unless @resource_request.path_stack.blank?
          format_id
          self.call_relation(entity)
        end
      )
    end

  # TODO: Should this be named "has_direct_relationships_to"?
    def self.has_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
      # This method defines that there are multiple links to members from an entity collection (an array of entity identifiers).
      # This adds an accessor instance method whose name is the entity's class.
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do
          entity_array = get_entity_id_from_relation_id.call(@resource_request.id)
          @resource_request.id, @resource_request.action = nil, nil
          ( @resource_request.id, @resource_request.action, @resource_request.path_stack ) = @resource_request.path_stack.split('/', 3) unless @resource_request.path_stack.blank?
          format_id
          unless entity_array.include?( @resource_request.id )
            raise HTTP404ResourceNotFound, 'Relation entity does not belong to referring resource.'
          end
          self.call_relation(entity)
        end
      )
    end

    def self.has_mapped_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
      # This method defines that there are mapped links to members from an entity collection (a hash of entity identifiers).
      # This adds an accessor instance method whose name is the entity's class.
      entity_name = opts[:as] || entity
      define_method( entity_name.to_sym,
        Proc.new do
          entity_map = get_entity_id_from_relation_id.call(@resource_request.id)
          @resource_request.action = nil
          ( key, @resource_request.action, @resource_request.path_stack ) = @resource_request.path_stack.split('/', 3) unless @resource_request.path_stack.blank?
          format_id
          unless @resource_request.id = entity_map[key.to_sym]
            raise HTTP404ResourceNotFound, 'Relation entity does not belong to referring resource.'
          end
          self.call_relation(entity)
        end
      )
    end

    def call_relation(entity)
      @resource_request.resource_name = entity.to_s.camelize
      setup_action
      @resource_request.locate
      @resource_request.call
    end

    def setup_action
      # If the action is not set with the request URI, determine the action from HTTP Verb.
      if @resource_request.action.blank?
        if @resource_request.request.get?
          @resource_request.action = @resource_request.id.blank? ? :index   : :show
        elsif @resource_request.request.put?
          @resource_request.action = @resource_request.id.blank? ? :replace : :update
        elsif @resource_request.request.post?
          @resource_request.action = @resource_request.id.blank? ? :create  : :add
        elsif @resource_request.request.delete?
          @resource_request.action = @resource_request.id.blank? ? :destroy : :delete
        else
          raise HTTP405MethodNotAllowed, 'Action not provided or found and unknown HTTP request method.'
        end
      end
    end

    def self.keyed_with_type(klass)
      # Allows decendent controllers to set a data type for the id other than the default.
      @@key_type = klass
    end

    def format_id
      # This method is used to convert the id coming off of the path stack, which is in string form, into another data type if one has been set.
      @@key_type ||= nil
      unless @@key_type.blank?
        if @@key_type == Fixnum
          @resource_request.id = @resource_request.id.to_i
        elsif @@key_type == Float
          @resource_request.id = @resource_request.id.to_f
        else
          raise HTTP500ServerError, "Invalid key identifier type specified on resource #{self.class.to_s}."
        end
      else
        @@key_type = String
      end
    end

    def package(data)
      # This handles outputing properly formatted content based on the file extension in the URL.
      if @resource_request.mime_type.like?( RESTRack.mime_type_for( :JSON ) )
        @output = data.to_json
      elsif @resource_request.mime_type.like?( RESTRack.mime_type_for( :XML ) )
        if File.exists? builder_file
          @output = builder_up(data)
        else
          # TODO: should it be @output = REXML::Document.new XmlSimple.xml_out data ?
          # I read today 11/29/2010 that REXML is no good, not sure on reliability of source.
          @output = XmlSimple.xml_out(data)
        end
      elsif @resource_request.mime_type.like?(RESTRack.mime_type_for( :YAML ) )
        @output = YAML.dump(data)
      elsif @resource_request.mime_type.like?(RESTRack.mime_type_for( :TEXT ) )
        @output = data.to_s
      else
        @output = data
      end
    end

    def builder_up(data)
      # Use Builder to generate the XML
      buffer = ''
      xml = Builder::XmlMarkup.new(:target => buffer)
      # TODO: Should xml.instruct! go here instead of each file?
      xml.instruct!
      # Search in templates/controller/action.xml.builder for the XML template
      # TODO: make sure it works from any execution path, i.e. you can fire up the web service from from different directories and template files are still found.
      eval( File.new( builder_file ).read )
      return buffer
    end

    def builder_file
      "#{RESTRack::CONFIG[:ROOT]}/views/#{@resource_request.resource_name.underscore}/#{@resource_request.action}.xml.builder"
    end

  end # class ResourceController
end # module RESTRack
