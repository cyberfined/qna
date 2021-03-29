RSpec.shared_examples_for 'API v1 showable' do
  before { do_request method, api_path, params: { access_token: access_token.token }, headers: headers }

  let(:json_entities) { json[json_key].kind_of?(Array) ? json[json_key] : [json[json_key]] }

  it 'returns successful status' do
    expect(response).to be_successful
  end

  it 'returns all entities' do
    ids = entities.map(&:id)
    expect(json_entities.count).to eq entities.count
    expect(json_entities).to be_all { |json_entity| ids.include? json_entity['id'] }
  end

  it "returns all entity's fields" do
    json_entities.each do |json_entity|
      entity = entities.find { |e| e.id == json_entity['id'] }
      assert_json_fields(entity, json_entity, json_fields)
    end
  end

  it "returns all entity's comments" do
    json_entities.each do |json_entity|
      entity = entities.find { |e| e.id == json_entity['id'] }
      expect(json_entity['comments'].count).to eq entity.comments.count
      json_entity['comments'].each do |json_comment| 
        comment = entity.comments.find_by(id: json_comment['id'])
        assert_json_fields(comment, json_comment, %w[body])
      end
    end
  end

  it "returns all entity's links" do
    json_entities.each do |json_entity|
      entity = entities.find { |e| e.id == json_entity['id'] }
      expect(json_entity['links'].count).to eq entity.links.count
      json_entity['links'].each do |json_link|
        link = entity.links.find_by(id: json_link['id'])
        if link.gist?
          expect(json_link['gist']).to eq true
          expect(json_link['content']).to eq link.gist_content.as_json
        else
          expect(json_link['gist']).to eq false
          assert_json_fields(link, json_link, %w[title url])
        end
      end
    end
  end

  it "returns all entity's files" do
    json_entities.each do |json_entity|
      entity = entities.find { |e| e.id == json_entity['id'] }
      expect(json_entity['files'].count).to eq entity.files.count
      json_entity['files'].each do |json_file|
        file = entity.files.find_by(id: json_file['id'])
        expect(json_file['filename']).to eq file.filename.as_json
        url = Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
        expect(json_file['url']).to eq url.as_json
      end
    end
  end
end
