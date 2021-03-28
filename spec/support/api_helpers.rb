module ApiHelpers
  def json
    @json ||= JSON.parse(response.body)
  end

  def do_request(method, path, options = {})
    send method, path, options
  end

  def assert_json_fields(obj, json, fields)
    fields.each { |field| expect(json[field]).to eq obj.send(field).as_json }
  end

  def assert_json_no_fields(json, fields)
    fields.each { |field| expect(json).to_not have_key field }
  end
end
