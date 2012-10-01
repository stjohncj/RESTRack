class SampleApp5::HookController < RESTRack::ResourceController

  def show(id)
    if id == 'pre_processor'
      { 'pre_processor_flag' => @resource_request.instance_variable_get(:@pre_processor_executed).to_s }
    else
      { 'neither' => true }
    end
  end

end
