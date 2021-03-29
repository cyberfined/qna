RSpec.describe 'profiles API', type: :request do
  let(:headers) {{ 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }}
  let!(:user) { create(:user) }
  let!(:access_token) { create(:access_token, resource_owner_id: user.id) }
  let(:public_fields) { %w[id email created_at updated_at] }
  let(:private_fields) { %w[encrypted_password reset_password_token
                            reset_password_sent_at remember_created_at admin] }

  describe 'GET /api/v1/profiles/me' do
    let(:api_path) { me_api_v1_profiles_path }
    it_behaves_like 'API v1 authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it "returns public user's fields" do
        assert_json_fields(user, json['user'], public_fields)
      end

      it "doesn't return private user's fields" do
        assert_json_no_fields(json['user'], private_fields)
      end
    end
  end

  describe 'GET /api/v1/profiles' do
    let(:api_path) { api_v1_profiles_path }
    let!(:users) { create_list(:user, 3) }
    it_behaves_like 'API v1 authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns all users' do
        ids = users.map(&:id)
        expect(json['users'].count).to eq users.count
        expect(json['users']).to be_all { |u| ids.include? u['id'] }
      end

      it "returns public user's fields" do
        json['users'].each do |user|
          assert_json_fields(users.find { |u| u.id == user['id'] }, user, public_fields)
        end
      end

      it "doesn't return private user's fields" do
        json['users'].each { |user| assert_json_no_fields(user, private_fields) }
      end
    end
  end
end
