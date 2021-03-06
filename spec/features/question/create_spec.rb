RSpec.feature 'User can ask a question', %q{
  In order to give answers from community
  As an authenticated user
  I'd like to ask a question
} do
  describe 'Authenticated user actions' do
    given!(:user) { create(:user) }
    given(:question) { build(:question) }
    given(:titleless_question) { build(:question, :titleless) }
    given(:bodyless_question) { build(:question, :bodyless) }

    before do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'
    end

    def ask_question(question)
      fill_in 'Title', with: question.title
      fill_in 'Body', with: question.body
      click_on 'Ask'
    end

    scenario 'User asks a question' do
      ask_question(question)

      expect(page).to have_content 'You have succesfully create a question'
    end

    scenario 'User tries to ask question with a blank title' do
      ask_question(titleless_question)

      expect(page).to have_content "Title can't be blank"
    end

    scenario 'User tries to ask question with a blank body' do
      ask_question(bodyless_question)

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries to ask a question' do
    visit questions_path
    click_on 'Ask question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
