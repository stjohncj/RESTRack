module RESTRack
  class WebService

# TODO: Work on logging, add to proper places, make all output work.
# TODO: Test IP logging
# TODO: Fix this: WARN -- : RESTRack::CONFIG[:DEFAULT_RESOURCE] should be a member of RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].
#         it happens on default config for new app
# TODO: Add Logger levels to config/constants.yaml

    def initialize
      # Establish the namespace pointer.
      RESTRack::CONFIG[:SERVICE_NAME] = self.class.to_s.split('::')[0].to_sym
    end

    def call( env )
      # Handle requests.
      request = Rack::Request.new(env)
      begin
        resource_request = RESTRack::ResourceRequest.new( :request => request )
        resource_request.locate
        resource_request.call
        response = resource_request.output
        return valid resource_request, response
      rescue Exception => exception
        return caught resource_request, exception
      end
    end # method call

    private

    def valid( resource_request, response )
      # Return HTTP200OK SUCCESS
      RESTRack.request_log.debug "'#{resource_request.mime_type.to_s}' response data (Request ID: #{resource_request.request_id})\n" + response.to_s unless not response.respond_to?( :to_s )
      RESTRack.request_log.info "HTTP200OK - (Request ID: #{resource_request.request_id})"
      return [200, {'Content-Type' => resource_request.content_type}, response ]
    end

    def caught( resource_request, exception )
      # Return appropriate response code and messages per raised exception type.
      if resource_request && resource_request.request_id
        RESTRack.request_log.info exception.message + "(Request ID: #{resource_request.request_id})"
      else
        RESTRack.request_log.info exception.message
      end
      case
        when exception.is_a?( HTTP400BadRequest )
          return [400, {'Content-Type' => 'text/plain'}, exception.message + "\nThe request cannot be fulfilled due to bad syntax." ]
        when exception.is_a?( HTTP401Unauthorized )
          return [401, {'Content-Type' => 'text/plain'}, exception.message + "\nYou have failed authentication for access to the resource." ]
        when exception.is_a?( HTTP403Forbidden )
          return [403, {'Content-Type' => 'text/plain'}, exception.message + "\nYou are forbidden to access that resource." ]
        when exception.is_a?( HTTP404ResourceNotFound )
          return [404, {'Content-Type' => 'text/plain'}, exception.message + "\nThe resource you requested could not be found." ]
        when exception.is_a?( HTTP405MethodNotAllowed )
          return [405, {'Content-Type' => 'text/plain'}, exception.message + "\nThe resource you requested does not support the request method provided." ]
        when exception.is_a?( HTTP409Conflict )
          return [409, {'Content-Type' => 'text/plain'}, exception.message + "\nThe resource you requested is in a conflicted state." ]
        when exception.is_a?( HTTP410Gone )
          return [410, {'Content-Type' => 'text/plain'}, exception.message + "\nThe resource you requested is no longer available." ]
        else # HTTP500ServerError
          msg = exception.message + "\n\n" + exception.backtrace.join("\n")
          if resource_request && resource_request.request_id
            RESTRack.log.error msg + " (Request ID: #{resource_request.request_id})\n\n"
          else
            RESTRack.log.error msg
          end
          return [500, {'Content-Type' => 'text/plain'}, msg ]
      end # case Exception
    end # method caught

  end # class WebService
end # module RESTRack
