RSpec.shared_examples_for 'API v1 authorizable' do
  context 'unathorized' do
    it 'returns unathorized error if there is no access token' do
      do_request(method, api_path, headers: headers)
      expect(response).to have_http_status :unauthorized
    end

    it 'returns unathorized error if access token is invalid' do
      do_request(method, api_path, params: { access_token: '12345' }, headers: headers)
      expect(response).to have_http_status :unauthorized
    end
  end
end
