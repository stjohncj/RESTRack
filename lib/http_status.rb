module RESTRack
  module HTTPStatus
    module ClientErrorCodes
      class HTTP400BadRequest       < Exception; end
      class HTTP403Forbidden        < Exception; end
      class HTTP404ResourceNotFound < Exception; end
      class HTTP405MethodNotAllowed < Exception; end
    end
  end
end