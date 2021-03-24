RSpec.feature 'User can ask a question', %q{
  In order to give answers from community
  As an authenticated user
  I'd like to ask a question
} do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }
    given(:question) { build(:question) }
    given(:titleless_question) { build(:question, :titleless) }
    given(:bodyless_question) { build(:question, :bodyless) }

    background do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'
    end

    def ask_question(question, files=[])
      fill_in 'Title', with: question.title
      fill_in 'Body', with: question.body
      attach_file 'Files', files unless files.empty?
      click_on 'Ask'
    end

    scenario 'asks a question' do
      ask_question(question)

      expect(page).to have_content 'You have succesfully create a question'
      expect(page).to have_content question.title
    end

    scenario 'asks a question with attached files' do
      files = [ Rails.root.join(Rails.public_path, '403.html'),
                Rails.root.join(Rails.public_path, '404.html') ]
      ask_question(question, files)

      expect(page).to have_content 'You have succesfully create a question'
      expect(page).to have_content question.title
      expect(page).to have_link '403.html'
      expect(page).to have_link '404.html'
    end

    scenario 'tries to ask question with a blank title' do
      ask_question(titleless_question)

      expect(page).to have_content "Title can't be blank"
    end

    scenario 'tries to ask question with a blank body' do
      ask_question(bodyless_question)

      expect(page).to have_content "Body can't be blank"
    end

    scenario 'watches a question that just have been created by another user', js: true do
      using_session('user') do
        sign_in(user)
        visit questions_path
        click_on 'Ask question'
      end

      using_session('another_user') do
        visit questions_path
        expect(page).to have_no_link question.title
      end

      using_session('user') do
        ask_question(question)
      end

      using_session('another_user') do
        expect(page).to have_link question.title
      end
    end
  end

  scenario 'Unauthenticated user tries to ask a question' do
    visit questions_path
    click_on 'Ask question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
