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
        @@log.debug "Initiating ResourceRequest Object"
        resource_request = RESTRack::ResourceRequest.new( :request => request )

        @@log.debug "Locating Resource (Request ID: #{resource_request.request_id})"
        begin
          resource_request.locate
        rescue
          return [404, {'Content-Type' => 'text/plain'}, 'The resource you requested could not be found.']
        end

        @@log.debug "Processing Request (Request ID: #{resource_request.request_id})"
        begin
          resource_request.call
        rescue PostInputException => e
          return [400, {'Content-Type' => 'text/plain'}, e.message]
        end

        @@log.debug "Retrieving Output (Request ID: #{resource_request.request_id})"
        response = resource_request.output
        content_type = resource_request.content_type

      rescue Exception => e
        if resource_request && resource_request.request_id
          msg = " (Request ID: #{resource_request.request_id})\n\n" + e.message + "\n\n" + e.backtrace.join("\n")
        else
          msg = e.message + "\n\n" + e.backtrace.join("\n")
        end
        @@log.error msg
        return [500, {'Content-Type' => 'text/plain'}, msg ]

      else
        # Success!
        @@request_log.info "#{resource_request.format} Data Out (Request ID: #{resource_request.request_id})\n" + response
        return [200, {'Content-Type' => content_type}, response ]
        # =======/
      end

    end # method call

  end # class WebService

  class MethodNotImplemented < Exception; end
  class PostInputException < Exception; end
  class UnhandledHTTPVerb < Exception; end

end # module RESTRack
