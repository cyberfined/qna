RSpec.feature 'User can log in', %q{
  In order to ask questions
  As an authenticated user
  I'd like to be able to log in
} do
  given(:user) { create(:user) }

  scenario 'Registered user logs in' do
    sign_in(user)

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'Unregistered user tries to log in' do
    visit new_user_session_path
    fill_in 'Email', with: 'unregistered@something.com'
    fill_in 'Password', with: 'password'
    click_on 'Log in'

    expect(page).to have_content 'Invalid Email or password'
  end
end
