module RESTRack
  class ResourceRequest
    attr_reader :request, :request_id, :input, :get_query_string, :get_query_hash
    attr_accessor :content_type, :controller_name, :format, :action, :id

    def initialize(opts)
      # Initialize the ResourceRequest by assigning a request_id and determining the path, format, and controller of the resource.
      # Accepting options just to allow us to override request_id for testing.
      @request = opts[:request]
      @request_id = opts[:request_id] || get_request_id

      # Gather input params
      input_str = @request.body.read
      @get_query_hash = @request.GET
      @get_query_string = @request.query_string

      # Pull input data from POST body if present, otherwise from GET query
      # TODO: Does this make sense? Perhaps support XML as a standard input and also binary types!
      # Can this inspect the content-type of the input, and load @input intelligently?
      @input = input_str.length > 0 ? JSON.parse( input_str ) : @get_query_hash

      # Write input details to logs
      RESTRack::WebService.request_log.info "Request Info (Request ID: #{@request_id})\n" + ({
        'ip' => @request.ip
      }).to_json
      RESTRack::WebService.log.debug "Reading POST Input as JSON (Request ID: #{@request_id})"
      RESTRack::WebService.request_log.info "JSON Data In (Request ID: #{@request_id})\n" + input_str

      # Path stack is the remaining URL path that hasn't been translated into resources and actions.
      # For the initial request this will be the entire request path.
     # @path_stack = @request.path_info
      # Load initial resource controller from the path stack.
     # setup_controller

# Parse out the controller of the resource being requested from the path.
      ( empty, @controller_name, @id, @action, @path_stack ) = @request.path_info.split('/', 5)
      # Determine the response format
      get_format
      # Set and return the controller
      @controller_name = RESTRack::Support.camelize( @controller_name )
    end

    def locate
      # Locate the correct controller of resource based on the request.
      # The resource requested must be a member of RESTRack application or a 404 error will be thrown by RESTRack::WebService.
      @resource = instantiate_controller
    end

    def call
      # Pass along the `call` method to the typed resource object, this must occur after a call to locate.
      @resource.call
    end

    def output
      # Send out the typed resource's output, this must occur after a call to run.
      @resource.output
    end

    #def setup_controller()
    #  # Get the controller name from the path stack, and get the path stack ready to satisfy the rest of the request.
    #  # Parse out the controller of the resource being requested from the path.
    #  ( empty, @controller_name, @id, @action, @path_stack ) = @path_stack.split('/', 5)
    #  # Determine the response format
    #  get_format if @format.nil?
    #  # Set and return the controller
    #  @controller_name = RESTRack::Support.camelize( @controller_name )
    #end

    private
    def get_request_id
      # TODO: Should this / can this be a more unique identifier?
      t = Time.now
      return t.strftime('%s') + t.usec.to_s
    end

    def get_format
      # Determine the format for the response.
      # Remove the extension from the URL if present, and use that to determine format.
      extension = ''
      unless @path_stack.nil?
        @path_stack = @path_stack.sub(/\.([^.]*)$/) do |s|
          extension = $1.downcase
          '' # Return an empty string as the substitution so that the extension is removed from `path_stack`
        end
      end
      if not get_query_hash.has_key?(format)
        # Get the format type requested, or use the default if none or unsupported was provided.
        @format = RESTRack::CONFIG[:DEFAULT_FORMAT]
        @format = :JSON if extension == 'json'
        @format = :XML if extension == 'xml'
      else
        @format = get_query_hash[format].upcase.to_sym
      end
    end

    def instantiate_controller
      # Called from the locate method, this method dynamically finds the class based on the URI and instantiates an object of that class.
      return Kernel.const_get( RESTRack::CONFIG[:SERVICE_NAME].to_sym ).const_get( "#{@controller_name}Controller".to_sym ).new(self)
    end

  end # module ResourceRequest
end # module RESTRack
