module RESTRack
  require 'mime/types'
  require 'yaml'
  require 'logger'

  class << self
    def log; @@log; end
    def request_log; @@request_log; end
  end # of class methods

  def self.load_config(file)
    config = YAML.load_file(file)
    # Open the logs on spin up.
    @@log                 ||= Logger.new( config[:LOG] )
    @@log.level             = Logger.const_get( config[:LOG_LEVEL] )
    @@request_log         ||= Logger.new( config[:REQUEST_LOG] )
    @@request_log.level     = Logger.const_get( config[:LOG_LEVEL] )
    # Do config validations
    if config[:ROOT_RESOURCE_ACCEPT].is_a?(Array) and config[:ROOT_RESOURCE_ACCEPT].length == 1 and config[:ROOT_RESOURCE_ACCEPT][0].lstrip.rstrip == ''
      config[:ROOT_RESOURCE_ACCEPT] = nil
      @@log.warn 'Improper format for RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT], should be nil or empty array not array containing empty string.'
    end
    if not config[:ROOT_RESOURCE_ACCEPT].blank? and not config[:DEFAULT_RESOURCE].blank? and not config[:ROOT_RESOURCE_ACCEPT].include?( config[:DEFAULT_RESOURCE] )
      @@log.warn 'RESTRack::CONFIG[:DEFAULT_RESOURCE] should be a member of RESTRack::CONFIG[:ROOT_RESOURCE_ACCEPT].'
    end
    config
  end

  def self.mime_type_for(format)
    MIME::Types.type_for(format.to_s.downcase)[0]
  end

  def self.controller_exists?(resource_name)
    begin
      return Kernel.const_get( RESTRack::CONFIG[:SERVICE_NAME].to_sym ).const_defined?( controller_name(resource_name).to_sym )
    rescue # constants can't start with numerics
      return false
    end
  end

  def self.controller_class_for(resource_name)
    Kernel.const_get( RESTRack::CONFIG[:SERVICE_NAME].to_sym ).const_get( controller_name(resource_name).to_sym )
  end

  def self.controller_name(resource_name)
    "#{resource_name.to_s.camelize}Controller".to_sym
  end

  def self.controller_has_action?(resource_name, action)
    controller_class_for(resource_name).const_defined?( action.to_sym )
  end

end

class Object
  def blank?
    # Courtesy of Rails' ActiveSupport, thank you DHH et al.
    respond_to?(:empty?) ? empty? : !self
  end
end

# We will support ".text" as an extension
MIME::Types['text/plain'][0].extensions << 'text'
MIME::Types.index_extensions( MIME::Types['text/plain'][0] )
