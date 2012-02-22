module RESTRack
  class WebService

    # Establish the namespace pointer.
    def initialize
      RESTRack::CONFIG[:SERVICE_NAME] = self.class.to_s.split('::')[0].to_sym
    end

    # Handle requests in the Rack way.
    def call( env )
      request = Rack::Request.new(env)
      begin
        resource_request = RESTRack::ResourceRequest.new( :request => request )
        response = resource_request.fulfill
        return valid resource_request, response
      rescue Exception => exception
        return caught resource_request, exception
      end
    end # method call

    private

    # Return HTTP200OK SUCCESS
    def valid( resource_request, response )
      RESTRack.log.debug "(#{resource_request.request_id}) HTTP200OK '#{resource_request.mime_type.to_s}' response data:\n" + response.to_s unless not response.respond_to?( :to_s )
      RESTRack.request_log.info "(#{resource_request.request_id}) HTTP200OK"
      return [200, {'Content-Type' => resource_request.content_type}, [response] ]
    end

    # Return appropriate response code and messages per raised exception type.
    def caught( resource_request, exception )
      # This will log the returned status code
      if resource_request && resource_request.request_id
        RESTRack.request_log.info "(#{resource_request.request_id}) #{exception.class.to_s} " + exception.message
      else
        RESTRack.request_log.info "(<nil-reqid>) #{exception.class.to_s} " + exception.message
      end
      case
        when exception.is_a?( HTTP400BadRequest )
          return [400, {'Content-Type' => 'text/plain'}, [exception.message || "The request cannot be fulfilled due to bad syntax."] ]
        when exception.is_a?( HTTP401Unauthorized )
          return [401, {'Content-Type' => 'text/plain'}, [exception.message || "You have failed authentication for access to the resource."] ]
        when exception.is_a?( HTTP403Forbidden )
          return [403, {'Content-Type' => 'text/plain'}, [exception.message || "You are forbidden to access that resource."] ]
        when exception.is_a?( HTTP404ResourceNotFound )
          return [404, {'Content-Type' => 'text/plain'}, [exception.message || "The resource you requested could not be found."] ]
        when exception.is_a?( HTTP405MethodNotAllowed )
          return [405, {'Content-Type' => 'text/plain'}, [exception.message || "The resource you requested does not support the request method provided."] ]
        when exception.is_a?( HTTP409Conflict )
          return [409, {'Content-Type' => 'text/plain'}, [exception.message || "The resource you requested is in a conflicted state."] ]
        when exception.is_a?( HTTP410Gone )
          return [410, {'Content-Type' => 'text/plain'}, [exception.message || "The resource you requested is no longer available."] ]
        when exception.is_a?( HTTP422ResourceInvalid )
          return [422, {'Content-Type' => 'text/plain'}, [exception.message || "Invalid attribute values sent for resource."] ]
        when exception.is_a?( HTTP502BadGateway )
          return [502, {'Content-Type' => 'text/plain'}, [exception.message || "The server was acting as a gateway or proxy and received an invalid response from the upstream server."] ]
        else # HTTP500ServerError
          if resource_request && resource_request.request_id
            RESTRack.log.error "(#{resource_request.request_id}) #{exception.class.to_s} " + exception.message + "\n" + exception.backtrace.join("\n")
          else
            RESTRack.log.error "(<nil-reqid>) #{exception.class.to_s} " + exception.message + "\n" + exception.backtrace.join("\n")
          end
          msg = ''
          if RESTRack::CONFIG[:SHOW_STACK]
            msg = (exception.message == exception.class.to_s) ? exception.backtrace.join("\n") : exception.message + "\nstack trace:\n" + exception.backtrace.join("\n")
          else
            msg = exception.message
          end
          return [500, {'Content-Type' => 'text/plain'}, [msg] ]
      end # case Exception
    end # method caught

  end # class WebService
end # module RESTRack
