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
    raise HTTP400BadRequest, package_error('tester')
  end

  def unauthorized
    raise HTTP401Unauthorized, package_error('tester')
  end

  def forbidden
    raise HTTP403Forbidden, package_error('tester')
  end

  def resource_not_found
    raise HTTP404ResourceNotFound, package_error('tester')
  end

  def method_not_allowed
    raise HTTP405MethodNotAllowed, package_error('tester')
  end

  def conflict
    raise HTTP409Conflict, package_error('tester')
  end

  def gone
    raise HTTP410Gone, package_error('tester')
  end

  def resource_invalid
    raise HTTP422ResourceInvalid, package_error({:message => 'This is a WebDAV HTTP extension code used by ActiveResource to communicate validation errors, rather than 400.'})
  end

  def server_error
    raise HTTP500ServerError, package_error('tester')
  end

end
