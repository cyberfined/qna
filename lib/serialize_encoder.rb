class SerializeEncoder
  def initialize(options={})
    @options = options
  end

  def encode(entity)
    ActiveModelSerializers::SerializableResource.new(entity, @options).to_json
  end

  def decode(data)
    ActiveSupport::JSON.decode(data)
  end
end
