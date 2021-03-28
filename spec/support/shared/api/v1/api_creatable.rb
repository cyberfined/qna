RSpec.shared_examples_for 'API v1 creatable' do
  let(:json_data) { ActiveModelSerializers::SerializableResource.new(entity).to_json }
  let(:invalid_json_data) { ActiveModelSerializers::SerializableResource.new(invalid_entity).to_json }

  it 'creates a new entity' do
    expect { do_request method, api_path, params: json_data, headers: auth_headers
    }.to change { entity.class.count }.by(1)
    expect(response).to be_successful
    new_entity = entity.class.find(json[entity.class.name.downcase]['id'])
    new_entity_json = ActiveModelSerializers::SerializableResource.new(new_entity).to_json
    expect(response.body).to eql new_entity_json
  end

  it 'tries to create a new entity' do
    expect { do_request method, api_path, params: invalid_json_data, headers: auth_headers
    }.to_not change { entity.class.count }
    expect(response).to have_http_status :unprocessable_entity
    expect(json).to have_key 'errors'
  end
end
