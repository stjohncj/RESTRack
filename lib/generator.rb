require 'erb'
require 'fileutils'
require 'rubygems'
require 'active_support/inflector'

module RESTRack
  class Generator
    TEMPLATE = {
      :service    => 'service.rb.erb',
      :constants  => 'constants.yaml.erb',
      :controller => 'controller.rb.erb'
    }
    
    class << self
      
      def generate_controller(name)
        template = get_template_for( :controller )
        resultant_string = template.result( get_binding_for_controller( name ) )
        File.open("#{name}/controllers/#{name}_controller.rb", 'w') {|f| f.puts resultant_string }
      end
  
      def generate_service(name)
        FileUtils.makedirs("#{name}/config")
        FileUtils.makedirs("#{name}/controllers")
        FileUtils.makedirs("#{name}/models")
        FileUtils.makedirs("#{name}/test")
        FileUtils.makedirs("#{name}/views")
        template = get_template_for( :service )
        resultant_string = template.result( get_binding_for_service( name ) )
        File.open("#{name}/loader.rb", 'w') {|f| f.puts resultant_string }
        
        template = get_template_for( :constants )
        resultant_string = template.result( get_binding_for_service( name ) )
        File.open("#{name}/config/constants.yaml", 'w') {|f| f.puts resultant_string }
      end
  
      private
  
      def get_template_for(type)
        template_file = File.new(File.join(File.dirname(__FILE__),"generator/#{TEMPLATE[type]}"))
        template = ERB.new( template_file.read, nil, "%" )
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
  
      def get_service_name
        # TODO: REFACTOR W/ RESCUE AND USING BASE_DIR
        file = nil
        if File.exists?( File.join( File.dirname(__FILE__), 'config/constants.yaml') )
          file = File.join( File.dirname(__FILE__), 'config/constants.yaml')
          # XXX: return File.dirname(__FILE__).split('/')[-1]
        elsif File.exists?( File.join( File.dirname(__FILE__), '../config/constants.yaml') )
          file = File.join( File.dirname(__FILE__), '../config/constants.yaml')
          # XXX: return File.dirname(__FILE__).split('/')[-2]
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
    
    end # class << self

  end # class
end # module
