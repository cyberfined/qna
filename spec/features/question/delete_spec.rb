RSpec.feature 'User can delete his question', %q{
  In order to other users dont spend their time on my question
  As an authenticated user
  I'd like to delete my question
} do
  describe 'Authenticated user actions' do
    given!(:user) { create(:user) }
    given(:another_user) { create(:user, :second) }
    given(:question) { user.questions.create!(attributes_for(:question)) }
    given(:another_question) { another_user.questions.create(attributes_for(:question)) }

    background do
      sign_in(user)
      visit questions_path
    end

    scenario 'User deletes his question' do
      click_on question.title
      click_on 'Delete'

      expect(page).to have_content 'You successfully delete the question'
    end

    scenario "User tries to delete other user's question" do
      click_on another_question.title
      
      expect(page).to have_no_button 'Delete'
    end
  end

  describe 'Unauthenticated user actions' do
    given(:user) { create(:user) }
    given(:question) { user.questions.create!(attributes_for(:question)) }

    scenario 'Unauthenticated user tries to delete a question' do
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Delete'
    end
  end
end
