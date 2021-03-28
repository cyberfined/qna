RSpec.shared_examples_for 'API v1 deletable' do
  let(:entity_path) { polymorphic_path([:api, :v1, entity]) }
  let(:another_entity_path) { polymorphic_path([:api, :v1, another_entity]) }

  it 'deletes an entity' do
    expect {
      do_request method, entity_path, headers: auth_headers
    }.to change { entity.class.count }.by(-1)
    expect(response).to be_successful
  end

  it "tries to delete another user's entity" do
    expect {
      do_request method, another_entity_path, headers: auth_headers
    }.to_not change { entity.class.count }
    expect(response).to have_http_status :forbidden
  end
end
