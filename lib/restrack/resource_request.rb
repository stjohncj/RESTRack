module RESTRack
  # The ResourceRequest class handles all incoming requests.
  class ResourceRequest
    attr_reader :request, :request_id, :params, :post_params, :get_params
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
      @post_params = parse_body( @request )
      @get_params = parse_query_string( @request )
      @params = {}
      # TODO: Test this!
      if @post_params.respond_to?(:merge)
        @params = @post_params.merge( @get_params )
      else
        @params = @get_params
      end
      RESTRack.log.debug 'combined params: ' + @params.inspect
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

    # Send out the typed resource's output.
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

    # This handles outputing properly formatted content based on the file extension in the URL.
    def package(data)
      if @mime_type.like?( RESTRack.mime_type_for( :JSON ) )
        @output = data.to_json
      elsif @mime_type.like?( RESTRack.mime_type_for( :XML ) )
        if File.exists? builder_file
          @output = builder_up(data)
        elsif data.respond_to?(:to_xml)
          @output = data.to_xml
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
      if @output.respond_to?(:each) # TODO: Should this do this?  Perhaps always bundle in array in web_service.rb
        return @output
      else
        return [@output]
      end
    end

    private
    def get_request_id
      t = Time.now
      return t.strftime('%FT%T') + '.' + t.usec.to_s
    end

    # Pull input data from POST body
    def parse_body(request)
      post_params = request.body.read
      RESTRack.log.debug "{#{@request_id}} #{request.content_type} raw POST data in:\n" + post_params.pretty_inspect
      unless request.content_type.blank?
        request_mime_type = MIME::Type.new( request.content_type )
        if request_mime_type.like?( RESTRack.mime_type_for( :JSON ) )
          post_params = JSON.parse( post_params ) rescue post_params
        elsif request_mime_type.like?( RESTRack.mime_type_for( :XML ) )
          post_params = XmlSimple.xml_in( post_params, 'ForceArray' => false ) rescue post_params
          post_params.each_key do |p|
            post_params[p] = nil if post_params[p]['nil'] # XmlSimple oddity
            if post_params[p].is_a? Hash and post_params[p]['type'] == 'integer'
              post_params[p] = post_params[p]['content'].to_i
            end
          end
        elsif request_mime_type.like?( RESTRack.mime_type_for( :YAML ) )
          post_params = YAML.parse( post_params ) rescue post_params
        end
      end
      RESTRack.log.debug "{#{@request_id}} #{request_mime_type.to_s} parsed POST data in:\n" + post_params.pretty_inspect
      post_params
    end

    def parse_query_string(request)
      get_params = request.GET
      RESTRack.log.debug "{#{@request_id}} GET data in:\n" + get_params.pretty_inspect
      get_params
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
      rescue Exception => e
        raise HTTP404ResourceNotFound, "The resource #{RESTRack::CONFIG[:SERVICE_NAME]}::#{RESTRack.controller_name(resource_name)} could not be instantiated."
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
