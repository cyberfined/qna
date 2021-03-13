RSpec.feature 'User can delete his answer', %q{
  In order to don't give wrong information
  As an authenticated user
  I'd like to delete my answer
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }

  describe 'Authenticated user' do
    background { sign_in(user) }

    scenario 'deletes his answer', js: true do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      visit questions_path
      click_on question.title
      click_on 'Delete answer'

      expect(page).to have_no_content answer.body
    end

    scenario "tries to delete another user's answer" do
      another_user = create(:user)
      answer = question.answers.create!(attributes_for(:answer, user: another_user))
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Delete answer'
    end
  end

  describe 'Unauthenticated user' do
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    scenario 'tries to delete an answer' do
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Delete answer'
    end
  end
end
