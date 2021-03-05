RSpec.feature 'User can log out', %q{
  In order to change account or protect it from another computer's users
  As an authenticated user
  I'd like to log out
} do
  given(:user) { create(:user) }

  scenario 'Authenticated user logs out' do
    sign_in(user)
    click_on 'Log out'

    expect(page).to_not have_content 'Log out'
  end
end
