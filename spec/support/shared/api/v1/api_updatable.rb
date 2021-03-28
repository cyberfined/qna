RSpec.shared_examples_for 'API v1 updatable' do
  let(:entity_path) { polymorphic_path([:api, :v1, entity]) }
  let(:another_entity_path) { polymorphic_path([:api, :v1, another_entity]) }
  let(:json_data) { ActiveModelSerializers::SerializableResource.new(new_valid_entity).to_json }
  let(:invalid_json_data) { ActiveModelSerializers::SerializableResource.new(new_invalid_entity).to_json }

  it 'updates an entity' do
    expect {
      do_request method, entity_path, params: json_data, headers: auth_headers
    }.to change { entity.reload.attributes }
    entity_json = ActiveModelSerializers::SerializableResource.new(entity).to_json
    expect(response).to be_successful
    expect(response.body).to eql entity_json
  end

  it 'tries to update entity with invalid attributes' do
    expect {
      do_request method, entity_path, params: invalid_json_data, headers: auth_headers
    }.to_not change { entity.reload.attributes }
    expect(response).to have_http_status :unprocessable_entity
    expect(json).to have_key 'errors'
  end

  it "tries to update another user's entity" do
    expect {
      do_request method, another_entity_path, params: json_data, headers: auth_headers
    }.to_not change { another_entity.reload.attributes }
    expect(response).to have_http_status :forbidden
  end
end
