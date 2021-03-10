RSpec.feature 'User can sign up', %q{
  In order to ask questions and answer on them
  As an unregistered user
  I'd like to sign up
} do
  given(:user) { build(:user) }
  given(:registered_user) { create(:user) }
  given(:invalid_email_user) { build(:user, :invalid_email) }
  given(:short_password_user) { build(:user, :short_password) }

  def sign_up(user)
    visit new_user_registration_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    click_on 'Sign up'
  end

  scenario 'User signs up' do
    sign_up(user)
    
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'User tries to sign up with a non-unique email' do
    sign_up(registered_user)

    expect(page).to have_content 'Email has already been taken'
  end

  scenario 'User tries to sign up with a wrong email value' do
    sign_up(invalid_email_user)

    expect(page).to have_content 'Email is invalid'
  end

  scenario 'User tries to sign up with a too short password' do
    sign_up(short_password_user)
    
    expect(page).to have_content 'Password is too short'
  end

  scenario 'User tries to sign up with wrong password confirmation value' do
    visit new_user_registration_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: 'wrong confirmation'
    click_on 'Sign up'

    expect(page).to have_content "Password confirmation doesn't match Password"
  end
end
