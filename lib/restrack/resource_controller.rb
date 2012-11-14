require 'restrack/resource_relations'

module RESTRack

  # All RESTRack controllers should descend from ResourceController.  This class
  # provides the methods for your controllers.
  #
  #                    HTTP Verb: |    GET    |   PUT     |   POST    |   DELETE
  # Collection URI (/widgets/):   |   index   |   replace |   create  |   drop
  # Element URI   (/widgets/42):  |   show    |   update  |   add     |   destroy
  #

  class ResourceController
    extend RESTRack::ResourceRelations

    attr_reader :action, :id, :params, :resource_request
    class << self; attr_accessor :key_type; end

    # Base initialization method for resources and storage of request input
    # This method should not be overriden in decendent classes.
    def self.__init(resource_request)
      __self = self.new
      return __self.__init(resource_request)
    end
    def __init(resource_request)
      @resource_request = resource_request
      @request = @resource_request.request
      @params = @resource_request.params
      @post_params = @resource_request.post_params
      @get_params = @resource_request.get_params
      self
    end

    # Call the controller's action and return output in the proper format.
    def call
      self.determine_action
      args = []
      args << @id unless @id.blank?
      unless self.respond_to?(@action.to_sym) or self.respond_to?(:method_missing)
        raise HTTP405MethodNotAllowed, 'Method not provided on controller.'
      end
      begin
        self.send(@action.to_sym, *args)
      rescue ArgumentError
        raise HTTP400BadRequest, 'Method called with the incorrect number of arguments. This is most likely due to a call to an action that accepts identifier, which was not supplied in URL.'
      end
    end

    # all internal methods are protected rather than private so that calling methods *could* be overriden if necessary.
    protected

    # This returns a datastructure which will automatically be converted by RESTRack
    # into the error format expected by ActiveResource.  ActiveResource expects
    # attribute input errors to be responded to with a status code of 422, which
    # is a non-standard HTTP code.  Use this to produce the required format of
    # "<errors><error>...</error><error>...</error></errors>" for the response XML.
    def package_error(error)
      ARFormattedError.new(error)
    end

    # Find the action, and id if relevant, that the controller must call.
    def determine_action
      term = @resource_request.url_chain.shift
      if term.nil?
        @id = nil
        @action = nil
      # id terms can be pushed on the url_stack which are not of type String by relationship handlers
      elsif term.is_a? String and self.methods.include?( term.to_sym )
        @id = self.methods.include?(@resource_request.url_chain[0]) ? nil : @resource_request.url_chain.shift
        @action = term.to_sym
      else
        begin
          self.class.format_string_id(term)
        rescue
          # if this isn't a valid id then it must be a request for an action that doesn't exist (we tested it as an action name above)
          raise HTTP405MethodNotAllowed, 'Action not provided or found and unknown HTTP request method.'
        end
        @id = term
        term = @resource_request.url_chain.shift
        if term.nil?
          @action = nil
        elsif self.methods.include?( term.to_sym )
          @action = term.to_sym
        else
          raise HTTP405MethodNotAllowed, 'Action not provided or found and unknown HTTP request method.'
        end
      end
      @id = self.class.format_string_id(@id) if @id.is_a? String
      # If the action is not set with the request URI, determine the action from HTTP Verb.
      get_action_from_context if @action.blank?
    end

    # This method is used to convert the id coming off of the path stack, which is in string form, into another data type if one has been set.
    def self.format_string_id(id)
      return nil unless id
      # default key type of resources is String
      self.key_type ||= String
      unless self.key_type.blank? or self.key_type.ancestors.include?(String)
        if self.key_type.ancestors.include?(Integer)
          id = Integer(id)
        elsif self.key_type.ancestors.include?(Float)
          id = Float(id)
        else
          raise HTTP500ServerError, "Invalid key identifier type specified on resource #{self.class.to_s}."
        end
      end
      id
    end

    # Get action from HTTP verb
    def get_action_from_context
      if @resource_request.request.get?
        @action = @id.blank? ? :index   : :show
      elsif @resource_request.request.put?
        @action = @id.blank? ? :replace : :update
      elsif @resource_request.request.post?
        @action = @id.blank? ? :create  : :add
      elsif @resource_request.request.delete?
        @action = @id.blank? ? :drop    : :destroy
      else
        raise HTTP405MethodNotAllowed, 'Action not provided or found and unknown HTTP request method.'
      end
    end

  end # class ResourceController
end # module RESTRack
