module RESTRack
  class ResourceController
    attr_reader :input, :output

    def initialize(resource_request)
      # Base initialization method for resources and storage of request input
      @resource_request = resource_request
      setup_action
    end

    def call
      # Call the controller's action and return it in the proper format.
      template( self.send(@resource_request.action, *@resource_request.id) )
    end

    #                    HTTP Verb: |    GET    |   PUT     |   POST    |   DELETE
    # Collection URI (/widgets/):   |   index   |   replace |   create  |   destroy
    # Element URI   (/widgets/42):  |   show    |   update  |   add     |   delete

    # Throw errors if RESTful methods are called but not implemented by descendent classes.
    def index;      raise MethodNotImplemented; end
    def replace;    raise MethodNotImplemented; end
    def create;     raise MethodNotImplemented; end
    def destroy;    raise MethodNotImplemented; end
    def show(id);   raise MethodNotImplemented; end
    def update(id); raise MethodNotImplemented; end
    def add(id);    raise MethodNotImplemented; end
    def delete(id); raise MethodNotImplemented; end

    protected
    def has_relation(entity)
      # Controller class' initialize method should set up a variable named from the decamelized version of the relation class name, whose value is the id of the relation.
      # adding accessor instance method with name from entity's Class
      self.class.define_method( entity.to_sym,
        Proc.new {
          self.resource_request.setup_controller
          return self.resource_request.locate
        }
      )
    end

    def has_relations(entities)
      # Controller class' initialize method should set up an Array named from the decamelized version of the relation class name, containing the id of each relation.
      # TODO: Complete this after getting has_relation method tested and finished.
    end

    def has_mapped_relations(entity_map)
      # Controller class' initialize method should set up an Hash named from the decamelized version of the relation class name, containing the id of each relation as values.
      # TODO: Complete this after getting has_relation method tested and finished.
    end

    def setup_action
      if @resource_request.action.nil?
        # Determine action from HTTP Verb
        if @resource_request.request.get?
          @resource_request.action = @resource_request.id.nil? ? :index   : :show
        elsif @resource_request.request.put?
          @resource_request.action = @resource_request.id.nil? ? :replace : :update
        elsif @resource_request.request.post?
          @resource_request.action = @resource_request.id.nil? ? :create  : :add
        elsif @resource_request.request.delete?
          @resource_request.action = @resource_request.id.nil? ? :destroy : :delete
        else
          raise UnhandledHTTPVerb
        end
      end
    end

    def template(data, content_type = nil)
      # This handles outputing properly formatted content based on the file extension in the URL.
      @resource_request.content_type = content_type
      case @resource_request.format
      when :JSON
        @output = data.to_json
        @resource_request.content_type ||= 'application/json'
      when :XML then
        @output = builder_up(data)
        @resource_request.content_type ||= 'text/xml'
      end
    end

    private
    def builder_up(data)
      # Use Builder to generate the XML
      buffer = ''
      xml = Builder::XmlMarkup.new(:target => buffer)
      # TODO: Should xml.instruct! go here instead of each file?
      xml.instruct!
      # Search in templates/controller/action.xml.builder for the XML template
      # TODO: make sure it works from any execution path, i.e. you can fire up the web service from from different directories and template files are still found.
      eval( File.new( "templates/#{@resource_request.controller_name}/#{@action}.xml.builder" ).read )
      return buffer
    end

  end # class ResourceController
end # module RESTRack
