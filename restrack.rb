%w[
  rubygems
  logger
  json
  find
].each do |file|
  require file
end

module RESTRack
  CONFIG = YAML.load_file('config/constants.yaml')
end

# Dynamically load all files in lib
Find.find(  File.join(File.dirname(__FILE__), 'lib') ) do |file|
  next if File.extname(file) != '.rb'
  require file
end

# We're letting consumers do raise HTTP400BadRequest
#    versus raise RESTRack::HTTPStatus::HTTP400BadRequest
include HTTPStatus