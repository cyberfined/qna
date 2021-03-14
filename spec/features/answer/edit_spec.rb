RSpec.feature 'User can edit his answer', %q{
  In order to correct my answer
  As an authenticated user
  I'd like to edit my answer
} do
  given!(:user) { create(:user) }
  given(:another_user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }

  describe 'Authenticated user' do
    context 'edits his answer', js: true do
      given(:answer) { build(:answer) }
      given(:new_valid_answer) { build(:answer, user: user) }
      given(:new_bodyless_answer) { build(:answer, :bodyless, user: user) }

      background do
        sign_in(user)
        visit questions_path
        click_on question.title

        fill_in 'answer[body]', with: answer.body
        click_on 'Answer'
      end

      def edit_answer(new_answer, files=[])
        click_on 'Edit answer'

        within '.answers' do
          fill_in 'answer[body]', with: new_answer.body
          attach_file 'answer[files][]', files unless files.empty?
          click_on 'Update answer'
        end
      end

      def have_no_form
        expect(page).to have_no_field 'answer[body]'
        expect(page).to have_no_field 'answer[files][]'
        expect(page).to have_no_button 'Update answer'
        expect(page).to have_button 'Edit answer'
      end

      scenario 'without errors' do
        edit_answer(new_valid_answer)

        within '.answers' do
          have_no_form
          expect(page).to have_no_content answer.body
          expect(page).to have_content new_valid_answer.body
        end
      end

      scenario 'without errors and with files attachment' do
        files = [ Rails.root.join(Rails.public_path, '403.html'),
                  Rails.root.join(Rails.public_path, '404.html') ]
        edit_answer(new_valid_answer, files)

        within '.answers' do
          have_no_form
          expect(page).to have_no_content answer.body
          expect(page).to have_content new_valid_answer.body
          expect(page).to have_link '403.html'
          expect(page).to have_link '404.html'
        end
      end

      scenario 'with blank body' do
        edit_answer(new_bodyless_answer)

        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario "tries to edit another user's answer" do
      another_answer = question.answers.create!(attributes_for(:answer, user: another_user))
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Edit answer'
    end
  end

  describe 'Unauthenticated user' do
    given!(:user) { create(:user) }
    given!(:question) { user.questions.create!(attributes_for(:question)) }
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    scenario 'tries to edit answer' do
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Edit answer'
    end
  end
end
