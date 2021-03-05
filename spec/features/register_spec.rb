RSpec.feature 'User can register a new account', %q{
  In order to ask questions and answer on them
  As an unregistered user
  I'd like to register a new account
} do
  given(:user) { build(:user) }
  given(:registered_user) { create(:user) }
  given(:invalid_email_user) { build(:user, :invalid_email) }
  given(:short_password_user) { build(:user, :short_password) }

  scenario 'User registers a new account' do
    sign_up(user)
    
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'User tries to register a new account with a non-unique email' do
    sign_up(registered_user)

    expect(page).to have_content 'Email has already been taken'
  end

  scenario 'User tries to register a new account with a wrong email value' do
    sign_up(invalid_email_user)

    expect(page).to have_content 'Email is invalid'
  end

  scenario 'User tries to register a new account with a too short password' do
    sign_up(short_password_user)
    
    expect(page).to have_content 'Password is too short'
  end

  scenario 'User tries to register a new account with wrong password confirmation value' do
    visit new_user_registration_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: 'wrong confirmation'
    click_on 'Sign up'

    expect(page).to have_content "Password confirmation doesn't match Password"
  end
end