RSpec.feature 'User can edit his question', %q{
  In order to correct my question
  As an authenticated user
  I'd like to edit it
} do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }
    given(:another_user) { create(:user) }
    given(:new_valid_question) { build(:question) }
    given(:new_titleless_question) { build(:question, :titleless) }
    given(:new_bodyless_question) { build(:question, :bodyless) }

    background { sign_in(user) }

    context 'edits his question', js: true do
      given!(:question) { user.questions.create!(attributes_for(:question)) }

      background do
        visit questions_path
        click_on question.title
        have_no_edit_form
      end

      def edit_question(new_question, files=[])
        click_on 'Edit question'

        fill_in 'question[title]', with: new_question.title
        fill_in 'question[body]', with: new_question.body
        attach_file 'question[files][]', files unless files.empty?
        click_on 'Update question'
      end

      def have_no_edit_form
        expect(page).to have_no_field 'question[title]'
        expect(page).to have_no_field 'question[body]'
        expect(page).to have_no_field 'question[files][]'
        expect(page).to have_no_button 'Update question'
        expect(page).to have_button 'Edit question'
      end

      scenario 'without errors' do
        edit_question(new_valid_question)

        have_no_edit_form
        expect(page).to have_no_content question.title
        expect(page).to have_no_content question.body
        expect(page).to have_content new_valid_question.title
        expect(page).to have_content new_valid_question.body
      end

      scenario 'without errors and with files attachment' do
        files = [ Rails.root.join(Rails.public_path, '403.html'),
                  Rails.root.join(Rails.public_path, '404.html') ]
        edit_question(new_valid_question, files)

        have_no_edit_form
        expect(page).to have_no_content question.title
        expect(page).to have_no_content question.body
        expect(page).to have_content new_valid_question.title
        expect(page).to have_content new_valid_question.body
        expect(page).to have_link '403.html'
        expect(page).to have_link '404.html'
      end

      scenario 'with blank title' do
        edit_question(new_titleless_question)

        expect(page).to have_content "Title can't be blank"
        expect(page).to have_no_content "Body can't be blank"
      end

      scenario 'with blank body' do
        edit_question(new_bodyless_question)

        expect(page).to have_content "Body can't be blank"
        expect(page).to have_no_content "Title can't be blank"
      end
    end

    scenario "tries to edit another user's question" do
      another_question = another_user.questions.create!(attributes_for(:question))
      visit questions_path
      click_on another_question.title

      expect(page).to have_no_button 'Edit question'
    end
  end

  describe 'Unauthenticated user' do
    given!(:user) { create(:user) }
    given!(:question) { user.questions.create!(attributes_for(:question)) }

    scenario 'tries to edit a question' do
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Edit question'
    end
  end
end
