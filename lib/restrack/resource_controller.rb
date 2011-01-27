module RESTRack
  
  # All RESTRack controllers should descend from ResourceController.  This class
  # provides the methods for your controllers.
  #
  #                    HTTP Verb: |    GET    |   PUT     |   POST    |   DELETE
  # Collection URI (/widgets/):   |   index   |   replace |   create  |   drop
  # Element URI   (/widgets/42):  |   show    |   update  |   add     |   destroy
  #
  #def index;       end
  #def replace;     end
  #def create;      end
  #def drop;        end
  #def show(id);    end
  #def update(id);  end
  #def add(id);     end
  #def destroy(id); end
  
  class ResourceController
    attr_reader :input, :output

    # Base initialization method for resources and storage of request input
    # This method should not be overriden in decendent classes.
    def self.__init(resource_request)
      __self = self.new
      return __self.__init(resource_request)
    end
    def __init(resource_request)
      @resource_request = resource_request
      setup_action
      self
    end

    # Call the controller's action and return it in the proper format.
    def call
      args = []
      args << @resource_request.id unless @resource_request.id.blank?
      package( self.send(@resource_request.action.to_sym, *args) )
    end

    def method_missing(method_sym, *arguments, &block)
      raise HTTP405MethodNotAllowed, 'Method not provided on controller.'
    end

    protected # all internal methods are protected rather than private so that calling methods *could* be overriden if necessary.
    # This method allows one to access a related resource, without providing a direct link to specific relation(s).
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

    # This method defines that there is a single link to a member from an entity collection.
    # The second parameter is an options hash to support setting the local name of the relation via ':as => :foo'.
    # The third parameter to the method is a Proc which accepts the calling entity's id and returns the id of the relation to which we're establishing the link.
    # This adds an accessor instance method whose name is the entity's class.
    def self.has_direct_relationship_to(entity, opts = {}, &get_entity_id_from_relation_id)
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

    # This method defines that there are multiple links to members from an entity collection (an array of entity identifiers).
    # This adds an accessor instance method whose name is the entity's class.
    def self.has_direct_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
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

    # This method defines that there are mapped links to members from an entity collection (a hash of entity identifiers).
    # This adds an accessor instance method whose name is the entity's class.
    def self.has_mapped_relationships_to(entity, opts = {}, &get_entity_id_from_relation_id)
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

    # Call the child relation (next entity in the path stack)
    # common logic to all relationship methods
    def call_relation(entity)
      @resource_request.resource_name = entity.to_s.camelize
      setup_action
      @resource_request.locate
      @resource_request.call
    end

    # If the action is not set with the request URI, determine the action from HTTP Verb.
    def setup_action
      if @resource_request.action.blank?
        if @resource_request.request.get?
          @resource_request.action = @resource_request.id.blank? ? :index   : :show
        elsif @resource_request.request.put?
          @resource_request.action = @resource_request.id.blank? ? :replace : :update
        elsif @resource_request.request.post?
          @resource_request.action = @resource_request.id.blank? ? :create  : :add
        elsif @resource_request.request.delete?
          @resource_request.action = @resource_request.id.blank? ? :drop    : :destroy
        else
          raise HTTP405MethodNotAllowed, 'Action not provided or found and unknown HTTP request method.'
        end
      end
    end

    # Allows decendent controllers to set a data type for the id other than the default.
    def self.keyed_with_type(klass)
      @@key_type = klass
    end

    # This method is used to convert the id coming off of the path stack, which is in string form, into another data type if one has been set.
    def format_id
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

    # This handles outputing properly formatted content based on the file extension in the URL.
    def package(data)
      if @resource_request.mime_type.like?( RESTRack.mime_type_for( :JSON ) )
        @output = data.to_json
      elsif @resource_request.mime_type.like?( RESTRack.mime_type_for( :XML ) )
        if File.exists? builder_file
          @output = builder_up(data)
        else
          @output = XmlSimple.xml_out(data, 'AttrPrefix' => true)
        end
      elsif @resource_request.mime_type.like?(RESTRack.mime_type_for( :YAML ) )
        @output = YAML.dump(data)
      elsif @resource_request.mime_type.like?(RESTRack.mime_type_for( :TEXT ) )
        @output = data.to_s
      else
        @output = data
      end
    end

    # Use Builder to generate the XML.
    def builder_up(data)
      buffer = ''
      xml = Builder::XmlMarkup.new(:target => buffer)
      xml.instruct!
      eval( File.new( builder_file ).read )
      return buffer
    end

    # Builds the path to the builder file for the current controller action.
    def builder_file
      "#{RESTRack::CONFIG[:ROOT]}/views/#{@resource_request.resource_name.underscore}/#{@resource_request.action}.xml.builder"
    end

  end # class ResourceController
end # module RESTRack
