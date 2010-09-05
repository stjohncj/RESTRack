module RESTRack

  CONFIG = YAML.load_file('config/constants.yaml')

  module Support

    class << self

      def camelize(str)
        str.split('_').collect { |s| s.split(//)[0].upcase + s[1,s.length-1] }.join
      end

      def decamelize(str)
        str.gsub(/([A-Za-z]*?)([A-Z][a-z])/) do |match|
          sub = $1.length == 0 ? '' : $1 + '_'
          sub += $2.downcase
        end
      end

    end # class methods

  end # module Support

end # module RESTRack