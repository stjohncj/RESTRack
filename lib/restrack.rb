%w[
  rack
  logger
  find
  yaml
  rubygems
  json
  xmlsimple
  builder
  active_support/inflector
  mime/types
].each do |file|
  require file
end

# Dynamically load all files in lib
Find.find(  File.join(File.dirname(__FILE__)) ) do |file|
  next if File.extname(file) != '.rb'
  puts 'loading file ' + file
  require file
end

include HTTPStatus
include ActiveSupport::Inflector
