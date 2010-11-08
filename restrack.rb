%w[
  logger
  find
  rubygems
  json
  xmlsimple
  mime/types
].each do |file|
  require file
end # TODO: Is mime/types being used?

# Dynamically load all files in lib
Find.find(  File.join(File.dirname(__FILE__), 'lib') ) do |file|
  next if File.extname(file) != '.rb'
  require file
end

# We're letting consumers do raise HTTP400BadRequest
#    versus raise RESTRack::HTTPStatus::HTTP400BadRequest
include HTTPStatus
