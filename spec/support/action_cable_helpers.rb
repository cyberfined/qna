module ActionCableHelpers
  def assert_broadcast_with_encoder(stream, data, coder: ActiveSupport::JSON)
    serialized_msg = coder.decode(coder.encode(data))
    new_messages = broadcasts(stream)
    message = new_messages.find { |msg| coder.decode(msg) == serialized_msg }
    assert message, "No messages sent with #{data} to #{stream}"
  end
end
