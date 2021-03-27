FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { 'Test app' }
    redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
    uid { 'uid' }
    secret { 'secret' }
  end
end
