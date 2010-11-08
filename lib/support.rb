module RESTRack
  module Support
    class << self
      # TODO: Are camelize/decamelize provided somewhere standard other than Rails?
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

class Object
  def blank?
    # Courtesy of Rails' ActiveSupport, thank you DHH et al.
    respond_to?(:empty?) ? empty? : !self
  end
end
