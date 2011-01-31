module RESTRack
  # The ResourceRequest class handles all incoming requests.
  class ResourceRequest
    attr_reader :request, :request_id, :input
    attr_accessor :mime_type, :url_chain

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
      @url_chain = @request.path_info.split('/')
      @url_chain.shift if @url_chain[0] == ''
      # Determine MIME type from extension
      extension = ''
      unless @url_chain[-1].nil?
        @url_chain[-1] = @url_chain[-1].sub(/\.([^.]*)$/) do |s|
          extension = $1.downcase
          '' # Return an empty string as the substitution so that the extension is removed from `@url_chain[-1]`
        end
      end
      @mime_type = get_mime_type_from( extension )
      # Pull first controller from URL
      controller_name = @url_chain.shift
      # Verify that initial resource in the request chain is accessible at the root.
      raise HTTP403Forbidden unless RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? or RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].include?(controller_name)
      raise HTTP403Forbidden if not RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? and RESTRack::CONFIG[:ROOT_RESOURCE_DENY].include?(controller_name)
      @active_controller = instantiate_controller( controller_name )
    end

    def content_type
      @mime_type.to_s
    end

    # Send out the typed resource's output, this must occur after a call to run.
    def response
      RESTRack.log.debug "{#{@request_id}} Retrieving Output"
      @active_controller.call
    end

    # Call the next entity in the path stack.
    # Method called by controller relationship methods.
    def call_controller(controller_name)
      @active_controller = instantiate_controller( controller_name.to_s.camelize )
      @active_controller.call
    end

    private
    def get_request_id
      t = Time.now
      return t.strftime('%FT%T') + '.' + t.usec.to_s
    end

    # Pull input data from POST body
    def read(request)
      input = ''
      unless request.content_type.blank?
        request_mime_type = MIME::Type.new( request.content_type )
        if request_mime_type.like?( RESTRack.mime_type_for( :JSON ) )
          input = JSON.parse( request.body.read )
        elsif request_mime_type.like?( RESTRack.mime_type_for( :XML ) )
          # TODO: CHECK THIS!  xml_out? or xml_in
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

    # Called from the locate method, this method dynamically finds the class based on the URI and instantiates an object of that class via the __init method on RESTRack::ResourceController.
    def instantiate_controller( controller_name )
      RESTRack.log.debug "{#{@request_id}} Locating Resource #{controller_name}"
      begin
        return RESTRack.controller_class_for( controller_name ).__init(self)
      rescue
        raise HTTP404ResourceNotFound, "The resource #{RESTRack::CONFIG[:SERVICE_NAME]}::#{RESTRack.controller_name(controller_name)} could not be instantiated."
      end
    end

  end # class ResourceRequest
end # module RESTRack
