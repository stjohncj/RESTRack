require 'erb'

module RESTRack
  class Generator

    def generate_controller(name)
      template = get_template_for( :controller )
      template.result( get_binding_for_controller( name ) )
      # write result
    end

    def generate_service(name)
      template = get_template_for( :service )
      template.result( get_binding_for_service( name ) )
      # write result
    end

    private

    def get_template_for(symbol)
      template = ERB.new File.new(File.join(File.dirname(__FILE__),"generator/#{symbol.to_s}")).read, nil, "%"
    end

    def get_binding_for_controller(name)
      @name = name
      @service_name = get_service_name
      binding
    end

    def get_binding_for_service(name)
      @service_name = name
      binding
    end
# TODO: Rename sample_app_1.rb etc to service.rb?
    def get_service_name
      # XXX: REFACTOR W/ RESCUE AND USING BASE_DIR
      file = nil
      if File.exists?( File.join( File.dirname(__FILE__), 'config/constants.yaml') )
        file = File.join( File.dirname(__FILE__), 'config/constants.yaml')
        #return File.dirname(__FILE__).split('/')[-1]
      elsif File.exists?( File.join( File.dirname(__FILE__), '../config/constants.yaml') )
        file = File.join( File.dirname(__FILE__), '../config/constants.yaml')
        #return File.dirname(__FILE__).split('/')[-2]
      end
      unless file.nil?
        File.open( file ) do |f|
          line = f.gets
          service_name = line.match(/#GENERATOR-CONST#.*Application-Namespace\s*=>\s*(.+)/)[0]
          return service_name
        end
      else
        raise 'Service name couldn\'t be determined.'
      end
    end

    def base_dir
      # TODO: Should this walk up the dir structure indefinitely?
      base_dir = nil
      if File.exists?( File.join( File.dirname(__FILE__), 'config/constants.yaml') )
        base_dir = File.dirname(__FILE__)
      elsif File.exists?( File.join( File.dirname(__FILE__), '../config/constants.yaml') )
        base_dir = File.join( File.dirname(__FILE__), '..')
      end
      base_dir
    end

  end
end
