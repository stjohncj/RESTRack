module RESTRack
  class Response
    attr_reader :status, :content_type, :body, :mime_type

    def initialize(request)
      @request = request
      begin
        @request.prepare
        RESTRack.log.debug "{#{@request.request_id}} Retrieving Output"
        @body = @request.active_controller.call
        @status = body.blank? ? 200 : 204
        RESTRack.log.debug "(#{@request.request_id}) HTTP200OK '#{@request.mime_type.to_s}' response data:\n" + @body.inspect
        RESTRack.request_log.info "(#{@request.request_id}) HTTP200OK"
      rescue Exception => exception
        # This will log the returned status code
        if @request && @request.request_id
          RESTRack.request_log.info "(#{@request.request_id}) #{exception.class.to_s} " + exception.message
        else
          RESTRack.request_log.info "(<nil-reqid>) #{exception.class.to_s} " + exception.message
        end
        case
          when exception.is_a?( HTTP400BadRequest )
            @status = 400
            @body = exception.message || 'The request cannot be fulfilled due to bad syntax.'
          when exception.is_a?( HTTP401Unauthorized )
            @status = 401
            @body = exception.message || 'You have failed authentication for access to the resource.'
          when exception.is_a?( HTTP403Forbidden )
            @status = 403
            @body = exception.message || 'You are forbidden to access that resource.'
          when exception.is_a?( HTTP404ResourceNotFound )
            @status = 404
            @body = exception.message || 'The resource you requested could not be found.'
          when exception.is_a?( HTTP405MethodNotAllowed )
            @status = 405
            @body = exception.message || 'The resource you requested does not support the request method provided.'
          when exception.is_a?( HTTP409Conflict )
            @status = 409
            @body = exception.message || 'The resource you requested is in a conflicted state.'
          when exception.is_a?( HTTP410Gone )
            @status = 410
            @body = exception.message || 'The resource you requested is no longer available.'
          when exception.is_a?( HTTP422ResourceInvalid )
            @status = 422
            @body = exception.message || 'Invalid attribute values sent for resource.'
          when exception.is_a?( HTTP502BadGateway )
            @status = 502
            @body = exception.message || 'The server was acting as a gateway or proxy and received an invalid response from the upstream server.'
          else # HTTP500ServerError
            server_error(exception)
        end # case Exception
      end # begin / rescue
      @mime_type = MIME::Type.new(@request.mime_type)
      @content_type = @request.content_type
    end

    def output
      return [status, {'Content-Type' => content_type}, [package(body)] ]
    end

    private
    def log_server_error(exception)
      if @request && @request.request_id
        RESTRack.log.error "(#{@request.request_id}) #{exception.class.to_s} " + exception.message + "\n" + exception.backtrace.join("\n")
      else
        RESTRack.log.error "(<nil-reqid>) #{exception.class.to_s} " + exception.message + "\n" + exception.backtrace.join("\n")
      end
    end

    def server_error(exception)
      log_server_error(exception)
      msg = ''
      if RESTRack::CONFIG[:SHOW_STACK]
        msg = (exception.message == exception.class.to_s) ? exception.backtrace.join("\n") : exception.message + "\nstack trace:\n" + exception.backtrace.join("\n")
      else
        msg = exception.message
      end
      @status = 500
      @body = msg || 'Server Error.'
    end

    # This handles outputing properly formatted content based on the file extension in the URL.
    def package(data)
      if mime_type.like?( RESTRack.mime_type_for( :JSON ) )
        output = data.to_json
      elsif mime_type.like?( RESTRack.mime_type_for( :XML ) )
        if File.exists? builder_file
          output = builder_up(data)
        elsif data.respond_to?(:to_xml)
          output = data.to_xml
        else
          output = XmlSimple.xml_out(data, 'AttrPrefix' => true, 'XmlDeclaration' => true, 'NoIndent' => true)
        end
      elsif mime_type.like?(RESTRack.mime_type_for( :YAML ) )
        output = YAML.dump(data)
      elsif mime_type.like?(RESTRack.mime_type_for( :TEXT ) )
        output = data.to_s
      else
        output = data
      end
      return output
    end # def package

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
      "#{RESTRack::CONFIG[:ROOT]}/views/#{@active_resource_name}/#{@request.active_controller.action}.xml.builder"
    end

  end # class Response
end # module RESTRack