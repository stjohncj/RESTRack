module HTTPStatus
  class HTTP400BadRequest       < Exception; end
  class HTTP401Unauthorized     < Exception; end
  class HTTP403Forbidden        < Exception; end
  class HTTP404ResourceNotFound < Exception; end
  class HTTP405MethodNotAllowed < Exception; end
  class HTTP409Conflict         < Exception; end
  class HTTP410Gone             < Exception; end
  class HTTP500ServerError      < Exception; end
end