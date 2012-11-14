class SampleApp5::HookController < RESTRack::ResourceController

  def show(id)
    if id == 'pre_processor'
      { 'pre_processor_flag' => @resource_request.instance_variable_get(:@pre_processor_executed).to_s }
    else
      { 'neither' => true }
    end
  end
  
  def dynamic_request
    @resource_request.instance_variable_set('@error_code', 123456)
    @resource_request.instance_variable_set('@error_message', 'Invalid password or email address combination')
  end

end