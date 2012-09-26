module RESTRack
  class WebService

    # Establish the namespace pointer.
    def initialize
      RESTRack::CONFIG[:SERVICE_NAME] = self.class.to_s.split('::')[0].to_sym
    end

    # Handle requests in the Rack way.
    def call( env )
      resource_request = RESTRack::ResourceRequest.new( :request => Rack::Request.new(env) )
      RESTRack::Hooks.pre_processor(resource_request) unless RESTRack::CONFIG.has_key?(:PRE_PROCESSOR_DISABLED) and RESTRack::CONFIG[:PRE_PROCESSOR_DISABLED]
      response = RESTRack::Response.new(resource_request)
      RESTRack::Hooks.post_processor(resource_request) unless RESTRack::CONFIG.has_key?(:POST_PROCESSOR_DISABLED) and RESTRack::CONFIG[:POST_PROCESSOR_DISABLED]
      return response.output
    end # method call

  end # class WebService
end # module RESTRack
