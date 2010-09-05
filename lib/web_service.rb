module RESTRack
  class WebService

    class << self
      def log; @@log; end
      def request_log; @@request_log; end
    end # of class methods

    def initialize
      # Open the logs on spin up.
      @@log ||= Logger.new( File.join( RESTRack::CONFIG[:LOG_ROOT], RESTRack::CONFIG[:LOG] ) )
      @@request_log ||= Logger.new( File.join( RESTRack::CONFIG[:LOG_ROOT], RESTRack::CONFIG[:REQUEST_LOG] ) )
    end

    def call(env)
      # Handle requests!
      request = Rack::Request.new(env)
      response = nil
      content_type = nil

      begin
        resource_request = RESTRack::ResourceRequest.new( :request => request )

        @@log.debug "Locating Resource (Request ID: #{resource_request.request_id})"
        resource_request.locate

        @@log.debug "Processing Request (Request ID: #{resource_request.request_id})"
        resource_request.call

        @@log.debug "Retrieving Output (Request ID: #{resource_request.request_id})"
        response = resource_request.output
        content_type = resource_request.content_type

      rescue Exception => e

        case e.class

          when HTTP400BadRequest
            return [400, {'Content-Type' => 'text/plain'}, "The request cannot be fulfilled due to bad syntax.\n" + e.message]

          when HTTP403Forbidden
            return [403, {'Content-Type' => 'text/plain'}, "You are forbidden to access that resource.\n" + e.message]

          when HTTP404ResourceNotFound
            return [404, {'Content-Type' => 'text/plain'}, "The resource you requested could not be found.\n" + e.message]

          when HTTP405MethodNotAllowed
            return [405, {'Content-Type' => 'text/plain'}, "The resource you requested does not support the request method provided.\n" + e.message]

        else # HTTP500InternalServerError
          if resource_request && resource_request.request_id
            msg = " (Request ID: #{resource_request.request_id})\n\n" + e.message + "\n\n" + e.backtrace.join("\n")
          else
            msg = e.message + "\n\n" + e.backtrace.join("\n")
          end
          @@log.error msg
          return [500, {'Content-Type' => 'text/plain'}, msg ]
        end

      else   # HTTP200OK
        @@request_log.info "#{resource_request.format} Data Out (Request ID: #{resource_request.request_id})\n" + response
        #       SUCCESS
        return [200, {'Content-Type' => content_type}, response ]
      end

    end # method call

  end # class WebService

end # module RESTRack