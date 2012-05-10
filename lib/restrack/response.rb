module RESTRack
  class Response
    attr_accessor :status, :content_type, :body

    def initialize(request)
      begin
        request.prepare
        body = request.process
        status = body.length > 0 ? 200 : 204
        RESTRack.log.debug "(#{request.request_id}) HTTP200OK '#{request.mime_type.to_s}' response data:\n" + response.to_s unless not response.respond_to?( :to_s )
        RESTRack.request_log.info "(#{request.request_id}) HTTP200OK"
      rescue => exception
        # This will log the returned status code
        if request && request.request_id
          RESTRack.request_log.info "(#{request.request_id}) #{exception.class.to_s} " + exception.message
        else
          RESTRack.request_log.info "(<nil-reqid>) #{exception.class.to_s} " + exception.message
        end
        case
          when exception.is_a?( HTTP400BadRequest )
            status = 400
            body = exception.message || 'The request cannot be fulfilled due to bad syntax.'
          when exception.is_a?( HTTP401Unauthorized )
            body = exception.message || 'You have failed authentication for access to the resource.'
          when exception.is_a?( HTTP403Forbidden )
            body = exception.message || 'You are forbidden to access that resource.'
          when exception.is_a?( HTTP404ResourceNotFound )
            body = exception.message || 'The resource you requested could not be found.'
          when exception.is_a?( HTTP405MethodNotAllowed )
            body = exception.message || 'The resource you requested does not support the request method provided.'
          when exception.is_a?( HTTP409Conflict )
            body = exception.message || 'The resource you requested is in a conflicted state.'
          when exception.is_a?( HTTP410Gone )
            body = exception.message || 'The resource you requested is no longer available.'
          when exception.is_a?( HTTP422ResourceInvalid )
            body = exception.message || 'Invalid attribute values sent for resource.'
          when exception.is_a?( HTTP502BadGateway )
            body = exception.message || 'The server was acting as a gateway or proxy and received an invalid response from the upstream server.'
          else # HTTP500ServerError
            server_error(request, exception)
        end # case Exception
      end # begin / rescue
      content_type = request.content_type
    end

    def output
      return [status, {'Content-Type' => content_type}, [Response.package(body)] ]
    end

    private
    def log_server_error(request, exception)
      if request && request.request_id
        RESTRack.log.error "(#{request.request_id}) #{exception.class.to_s} " + exception.message + "\n" + exception.backtrace.join("\n")
      else
        RESTRack.log.error "(<nil-reqid>) #{exception.class.to_s} " + exception.message + "\n" + exception.backtrace.join("\n")
      end
    end

    def server_error(request, exception)
      log_server_error(request, exception)
      msg = ''
      if RESTRack::CONFIG[:SHOW_STACK]
        msg = (exception.message == exception.class.to_s) ? exception.backtrace.join("\n") : exception.message + "\nstack trace:\n" + exception.backtrace.join("\n")
      else
        msg = exception.message
      end
      status = 500
      body = msg || 'Server Error.'
    end

    class << self
      # This handles outputing properly formatted content based on the file extension in the URL.
      def package(data)
        if @mime_type.like?( RESTRack.mime_type_for( :JSON ) )
          output = data.to_json
        elsif @mime_type.like?( RESTRack.mime_type_for( :XML ) )
          if File.exists? builder_file
            output = builder_up(data)
          elsif data.respond_to?(:to_xml)
            output = data.to_xml
          else
            output = XmlSimple.xml_out(data, 'AttrPrefix' => true, 'XmlDeclaration' => true, 'NoIndent' => true)
          end
        elsif @mime_type.like?(RESTRack.mime_type_for( :YAML ) )
          output = YAML.dump(data)
        elsif @mime_type.like?(RESTRack.mime_type_for( :TEXT ) )
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
        "#{RESTRack::CONFIG[:ROOT]}/views/#{@active_resource_name}/#{@active_controller.action}.xml.builder"
      end
    end # class << self

  end # class Response
end # module RESTRack