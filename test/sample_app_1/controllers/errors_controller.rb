class SampleApp::ErrorsController < RESTRack::ResourceController

  #module HTTPStatus
  #  class HTTP400BadRequest       < Exception; end
  #  class HTTP401Unauthorized     < Exception; end
  #  class HTTP403Forbidden        < Exception; end
  #  class HTTP404ResourceNotFound < Exception; end
  #  class HTTP405MethodNotAllowed < Exception; end
  #  class HTTP409Conflict         < Exception; end
  #  class HTTP410Gone             < Exception; end
  #  class HTTP500ServerError      < Exception; end
  #end

  def bad_request
    raise HTTP400BadRequest, 'tester'
  end

  def unauthorized
    raise HTTP401Unauthorized, 'tester'
  end

  def forbidden
    raise HTTP403Forbidden, 'tester'
  end

  def resource_not_found
    raise HTTP404ResourceNotFound, 'tester'
  end

  def method_not_allowed
    raise HTTP405MethodNotAllowed, 'tester'
  end

  def conflict
    raise HTTP409Conflict, 'tester'
  end

  def gone
    raise HTTP410Gone, 'tester'
  end

  def server_error
    raise HTTP500ServerError, 'tester'
  end

end
