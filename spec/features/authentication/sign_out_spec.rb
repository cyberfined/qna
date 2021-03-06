RSpec.feature 'User can sign out', %q{
  In order to change account or protect it from another computer's users
  As an authenticated user
  I'd like to sign out
} do
  given(:user) { create(:user) }

  scenario 'Authenticated user signs out' do
    sign_in(user)
    click_on 'Sign out'

    expect(page).to_not have_content 'Sign out'
  end
end
