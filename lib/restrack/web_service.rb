module RESTRack
  class WebService

    # Establish the namespace pointer.
    def initialize
      RESTRack::CONFIG[:SERVICE_NAME] = self.class.to_s.split('::')[0].to_sym
    end

    # Handle requests in the Rack way.
    def call( env )
      resource_request = RESTRack::ResourceRequest.new( :request => Rack::Request.new(env) )
      response = RESTRack::Response.new(resource_request)
      return response.output
    end # method call

  end # class WebService
end # module RESTRack
