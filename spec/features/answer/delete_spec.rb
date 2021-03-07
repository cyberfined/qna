RSpec.feature 'User can delete his answer', %q{
  In order to don't give wrong information
  As an authenticated user
  I'd like to delete my answer
} do
  given!(:user) { create(:user) }

  describe "Authenticated user's actions" do
    background { sign_in(user) }

    context 'Valid actions' do
      given!(:question) { user.questions.create!(attributes_for(:question)) }
      given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

      scenario 'User deletes his answer' do
        visit questions_path
        click_on question.title
        click_on 'Delete answer'

        expect(page).to have_no_content answer.body
      end
    end

    context 'Invalid actions' do
      given!(:another_user) { create(:user, :second) }
      given!(:question) { user.questions.create!(attributes_for(:question)) }
      given!(:answer) { question.answers.create!(attributes_for(:answer, user: another_user)) }

      scenario "User tries to delete another user's answer" do
        visit questions_path
        click_on question.title

        expect(page).to have_no_content 'Delete answer'
      end
    end
  end

  describe "Unauthenticated user's actions" do
    given!(:question) { user.questions.create!(attributes_for(:question)) }
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    scenario 'Unauthenticated user tries to delete an answer' do
      visit questions_path
      click_on question.title

      expect(page).to have_no_content 'Delete answer'
    end
  end
end
