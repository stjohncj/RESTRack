module RESTRack
  # The ResourceRequest class handles all incoming requests.
  class ResourceRequest
    attr_reader :request, :request_id, :input
    attr_accessor :mime_type, :path_stack, :resource_name, :action, :id

    # Initialize the ResourceRequest by assigning a request_id and determining the path, format, and controller of the resource.
    # Accepting options to allow us to override request_id for testing.
    def initialize(opts)
      @request = opts[:request]
      @request_id = opts[:request_id] || get_request_id

      # Write input details to logs
      RESTRack.request_log.info "{#{@request_id}} #{@request.path_info} requested from #{@request.ip}"

      RESTRack.log.debug "{#{@request_id}} Reading POST Input"

      # Pull input data from POST body
      @input = read( @request )

      # Setup up the initial routing.
      (@path_stack, extension)      = split_extension_from( @request.path_info )
      @mime_type                    = get_mime_type_from( extension )
      (@resource_name, @path_stack) = get_initial_resource_from( @path_stack )
      (@id, @action, @path_stack)   = get_id_and_action_from( @path_stack )

      # Verify that initial resource in the request chain is accessible at the root.
      raise HTTP403Forbidden unless RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? or RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].include?(@resource_name)
      raise HTTP403Forbidden if not RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? and RESTRack::CONFIG[:ROOT_RESOURCE_DENY].include?(@resource_name)
    end

    # Locate the correct controller of resource based on the request.
    # The resource requested must be a member of RESTRack application or a 404 error will be thrown by RESTRack::WebService.
    def locate
      RESTRack.log.debug "{#{@request_id}} Locating Resource"
      @resource = instantiate_controller
    end

    # Pass along the `call` method to the typed resource object, this must occur after a call to locate.
    def call
      RESTRack.log.debug "{#{@request_id}} Processing Request"
      @resource.call
    end

    # Send out the typed resource's output, this must occur after a call to run.
    def output
      RESTRack.log.debug "{#{@request_id}} Retrieving Output"
      @resource.output
    end

    def content_type
      @mime_type.to_s
    end

    private
    def get_request_id
      t = Time.now
      return t.strftime('%FT%T') + '.' + t.usec.to_s
    end

    def read(request)
      input = ''
      unless request.content_type.blank?
        request_mime_type = MIME::Type.new( request.content_type )
        if request_mime_type.like?( RESTRack.mime_type_for( :JSON ) )
          input = JSON.parse( request.body.read )
        elsif request_mime_type.like?( RESTRack.mime_type_for( :XML ) )
          input = XmlSimple.xml_out( request.body.read )
        elsif request_mime_type.like?( RESTRack.mime_type_for( :YAML ) )
          input = YAML.parse( request.body.read )
        elsif request_mime_type.like?( RESTRack.mime_type_for( :TEXT ) )
          input = request.body.read.to_s
        else
          input = request.body.read
        end
        RESTRack.request_log.debug "{#{@request_id}} #{request_mime_type.to_s} data in\n" + input.to_json
      end
      input
    end

    # Remove the extension from the URL if present, that will be used to determine content-type.
    def split_extension_from(path_stack)
      extension = ''
      unless path_stack.nil?
        path_stack = path_stack.sub(/\.([^.]*)$/) do |s|
          extension = $1.downcase
          '' # Return an empty string as the substitution so that the extension is removed from `path_stack`
        end
      end
      [path_stack, extension]
    end

    def get_mime_type_from(extension)
      unless extension == ''
        mime_type = RESTRack.mime_type_for( extension )
      end
      if mime_type.nil?
        if RESTRack::CONFIG[:DEFAULT_FORMAT]
          mime_type = RESTRack.mime_type_for( RESTRack::CONFIG[:DEFAULT_FORMAT].to_s.downcase )
        else
          mime_type = RESTRack.mime_type_for( :JSON )
        end
      end
      mime_type
    end

    def get_initial_resource_from(orig_path_stack)
      ( empty_str, resource_name, path_stack ) = orig_path_stack.split('/', 3)
      if resource_name.blank? or not RESTRack.resource_exists? resource_name # treat as if request to default resource
        raise HTTP404ResourceNotFound if RESTRack::CONFIG[:DEFAULT_RESOURCE].blank?
        path_stack = orig_path_stack.sub(/^\//, '')
        resource_name = RESTRack::CONFIG[:DEFAULT_RESOURCE]
      end
      [resource_name, path_stack]
    end

    def get_id_and_action_from(path_stack)
      ( id, action, path_stack ) = (path_stack || '').split('/', 3)
      if [ :index, :replace, :create, :destroy ].include? id
        action = id
        id = nil
      end
      [id, action, path_stack]
    end

    # Called from the locate method, this method dynamically finds the class based on the URI and instantiates an object of that class via the __init method on RESTRack::ResourceController.
    def instantiate_controller
      begin
        return RESTRack.controller_class_for( @resource_name ).__init(self)
      rescue
        raise HTTP404ResourceNotFound, "The resource #{RESTRack::CONFIG[:SERVICE_NAME]}::#{RESTRack.controller_name(@resource_name)} could not be instantiated."
      end
    end

  end # class ResourceRequest
end # module RESTRack
