module RESTRack
  # The ResourceRequest class handles all incoming requests.
  class ResourceRequest
    attr_reader :request, :request_id, :input, :params
    attr_accessor :mime_type, :url_chain

    # Initialize the ResourceRequest by assigning a request_id and determining the path, format, and controller of the resource.
    # Accepting options to allow us to override request_id for testing.
    def initialize(opts)
      @request = opts[:request]
      @request_id = opts[:request_id] || get_request_id
      # Write input details to logs
      RESTRack.request_log.info "{#{@request_id}} #{@request.path_info} requested from #{@request.ip}"
    end
    
    def fulfill
      self.prepare
      return self.response
    end
    
    def prepare
      # Pull input data from POST body
      @input = parse_body( @request )
      @params = get_params( @request )
      # Setup up the initial routing.
      @url_chain = @request.path_info.split('/')
      @url_chain.shift if @url_chain[0] == ''
      # Pull extension from URL
      extension = ''
      unless @url_chain[-1].nil?
        @url_chain[-1] = @url_chain[-1].sub(/\.([^.]*)$/) do |s|
          extension = $1.downcase
          '' # Return an empty string as the substitution so that the extension is removed from `@url_chain[-1]`
        end
      end
      # Determine MIME type from extension
      @mime_type = get_mime_type_from( extension )
      # Pull first controller from URL
      @active_resource_name = @url_chain.shift
      unless @active_resource_name.nil? or RESTRack.controller_exists?(@active_resource_name)
        @url_chain.unshift( @active_resource_name )
      end
      if @active_resource_name.nil? or not RESTRack.controller_exists?(@active_resource_name)
        raise HTTP404ResourceNotFound unless RESTRack::CONFIG[:DEFAULT_RESOURCE]
        @active_resource_name = RESTRack::CONFIG[:DEFAULT_RESOURCE] 
      end
      raise HTTP403Forbidden unless RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].blank? or RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].include?(@active_resource_name)
      raise HTTP403Forbidden if not RESTRack::CONFIG[:ROOT_RESOURCE_DENY].blank? and RESTRack::CONFIG[:ROOT_RESOURCE_DENY].include?(@active_resource_name)
      @active_controller = instantiate_controller( @active_resource_name )
    end

    # Send out the typed resource's output, this must occur after a call to run.
    def response
      RESTRack.log.debug "{#{@request_id}} Retrieving Output"
      package( @active_controller.call )
    end

    # Call the next entity in the path stack.
    # Method called by controller relationship methods.
    def call_controller(resource_name)
      @active_resource_name = resource_name
      @active_controller = instantiate_controller( resource_name.to_s.camelize )
      @active_controller.call
    end

    def content_type
      @mime_type.to_s
    end

    private
    def get_request_id
      t = Time.now
      return t.strftime('%FT%T') + '.' + t.usec.to_s
    end

    # Pull input data from POST body
    def parse_body(request)
      input = request.body.read
      unless request.content_type.blank?
        request_mime_type = MIME::Type.new( request.content_type )
        if request_mime_type.like?( RESTRack.mime_type_for( :JSON ) )
          input = JSON.parse( input )
        elsif request_mime_type.like?( RESTRack.mime_type_for( :XML ) )
          input = XmlSimple.xml_in( input, 'ForceArray' => false )
        elsif request_mime_type.like?( RESTRack.mime_type_for( :YAML ) )
          input = YAML.parse( input )
        end
      end
      RESTRack.log.debug "{#{@request_id}} #{request_mime_type.to_s} data in:\n" + input.pretty_inspect
      input
    end
    
    def get_params(request)
      params = request.GET
    end

    # Determine the MIME type of the request from the extension provided.
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
    def instantiate_controller( resource_name )
      RESTRack.log.debug "{#{@request_id}} Locating Resource #{resource_name}"
      begin
        return RESTRack.controller_class_for( resource_name ).__init(self)
      rescue
        raise HTTP404ResourceNotFound, "The resource #{RESTRack::CONFIG[:SERVICE_NAME]}::#{RESTRack.controller_name(resource_name)} could not be instantiated."
      end
    end

    # This handles outputing properly formatted content based on the file extension in the URL.
    def package(data)
      if @mime_type.like?( RESTRack.mime_type_for( :JSON ) )
        @output = data.to_json
      elsif @mime_type.like?( RESTRack.mime_type_for( :XML ) )
        if File.exists? builder_file
          @output = builder_up(data)
        else
          @output = XmlSimple.xml_out(data, 'AttrPrefix' => true, 'XmlDeclaration' => true, 'NoIndent' => true)
        end
      elsif @mime_type.like?(RESTRack.mime_type_for( :YAML ) )
        @output = YAML.dump(data)
      elsif @mime_type.like?(RESTRack.mime_type_for( :TEXT ) )
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
      "#{RESTRack::CONFIG[:ROOT]}/views/#{@active_resource_name}/#{@active_controller.action}.xml.builder"
    end

  end # class ResourceRequest
end # module RESTRack
