module RESTRack
  class ResourceRequest
    attr_reader :request, :request_id, :input
    attr_accessor :mime_type, :path_stack, :resource_name, :action, :id

    def initialize(opts)
      # Initialize the ResourceRequest by assigning a request_id and determining the path, format, and controller of the resource.
      # Accepting options just to allow us to override request_id for testing.
      @request = opts[:request]
      @request_id = opts[:request_id] || get_request_id

      # Write input details to logs
      RESTRack.request_log.info "Request ID: #{@request_id}\n" + ({
        'ip' => @request.ip
      }).to_json

      RESTRack.log.debug "Reading POST Input (Request ID: #{@request_id})"
      # Pull input data from POST body
      unless @request.content_type.blank?
        request_mime_type = MIME::Type.new( @request.content_type )
        if request_mime_type.like?( MIME::Types['application/json'][0] )
          @input = JSON.parse( @request.body.read )
        elsif request_mime_type.like?( MIME::Types['application/xml'][0] )
          @input = XmlSimple.xml_out( @request.body.read )
        elsif request_mime_type.like?( MIME::Types['text/x-yaml'][0] )
          @input = YAML.parse( @request.body.read )
        elsif request_mime_type.like?( MIME::Types['text/plain'][0] )
          @input = @request.body.read.to_s
        else
          @input = @request.body.read
        end
        RESTRack.request_log.debug "#{request_mime_type.to_s} Data In (Request ID: #{@request_id})\n" + @input.to_json
      end

      # Setup up the initial routing.
      get_initial_route
      # Verify that initial resource in the request chain is accessible at the root.
      raise HTTP403Forbidden unless RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? or RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].include?(@resource_name)
      raise HTTP403Forbidden if not RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? and RESTRack::CONFIG[:ROOT_RESOURCE_DENY].include?(@resource_name)
      # Set and return the controller
      @resource_name = @resource_name.camelize
    end

    def locate
      # Locate the correct controller of resource based on the request.
      # The resource requested must be a member of RESTRack application or a 404 error will be thrown by RESTRack::WebService.
      RESTRack.log.debug "Locating Resource (Request ID: #{@request_id})"
      @resource = instantiate_controller
    end

    def call
      # Pass along the `call` method to the typed resource object, this must occur after a call to locate.
      RESTRack.log.debug "Processing Request (Request ID: #{@request_id})"
      @resource.call
    end

    def output
      # Send out the typed resource's output, this must occur after a call to run.
      RESTRack.log.debug "Retrieving Output (Request ID: #{@request_id})"
      @resource.output
    end

    def content_type
      @mime_type.to_s
    end

    private
    def get_request_id
      # TODO: Should this / can this be a more unique identifier?
      t = Time.now
      return t.strftime('%s') + ':' + t.usec.to_s
    end

    def get_initial_route
      # Determine the initial resource to call and what format the request is in.
      # Path stack keeps track of what on the requets path is yet to be followed.
      @path_stack = @request.path_info
      # Determine the response format
      get_format
      # @path_stack will start with a forward slash here, so the first item returned will be an empty string.
      ( empty_str, @resource_name, @id, @action, @path_stack ) = @path_stack.split('/', 5)
      # To allow default route for case when resource name is not provided but is assumed.
      if [ :index, :replace, :create, :destroy ].include? @resource_name
        @action = @resource_name
        @resource_name = nil
      elsif [ :index, :replace, :create, :destroy ].include? @id
        @action = @id
        @id = nil
      elsif [ :show, :update, :add, :delete ].include? @id
        @id = @resource_name
        @resource_name = nil
      end
      @resource_name = RESTRack::CONFIG[:DEFAULT_RESOURCE] if @resource_name.blank?
    end

    def get_format
      # Determine the format for the response.
      # Remove the extension from the URL if present, and use that to determine content-type.
      extension = ''
      unless @path_stack.nil?
        @path_stack = @path_stack.sub(/\.([^.]*)$/) do |s|
          extension = $1.downcase
          '' # Return an empty string as the substitution so that the extension is removed from `path_stack`
        end
      end
      unless extension == ''
        @mime_type = RESTRack.mime_type_for( extension )
      end
      if @mime_type.nil?
        if RESTRack::CONFIG[:DEFAULT_FORMAT]
          @mime_type = RESTRack.mime_type_for( RESTRack::CONFIG[:DEFAULT_FORMAT].to_s.downcase )
        else
          @mime_type = RESTRack.mime_type_for( :JSON )
          # TODO: Should this be an HTTP Error response?
        end
      end
    end

    def instantiate_controller
      # Called from the locate method, this method dynamically finds the class based on the URI and instantiates an object of that class via the __init method on RESTRack::ResourceController.
      begin
        return Kernel.const_get( RESTRack::CONFIG[:SERVICE_NAME].to_sym ).const_get( "#{@resource_name}Controller".to_sym ).__init(self)
      rescue
        raise HTTP404ResourceNotFound, "The resource #{RESTRack::CONFIG[:SERVICE_NAME]}::#{@resource_name}Controller could not be instantiated."
      end
    end

  end # class ResourceRequest
end # module RESTRack
