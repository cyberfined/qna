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

      before do
        visit questions_path
        click_on question.title
        expect(page).to have_no_field 'question[title]'
        expect(page).to have_no_field 'question[body]'
        expect(page).to have_no_button 'Update question'
      end

      def edit_question(new_question)
        click_on 'Edit question'

        page.document.synchronize do
          if page.has_field? 'question[title]'
            fill_in 'question[title]', with: new_question.title
            fill_in 'question[body]', with: new_question.body
            click_on 'Update question'
          else
            nil
          end
        end
      end

      scenario 'with no errors' do
        edit_question(new_valid_question)

        page.document.synchronize seconds=20 do
          if page.has_no_content? question.title
            expect(page).to have_no_field 'question[title]'
            expect(page).to have_no_field 'question[body]'
            expect(page).to have_no_button 'Update question'
            expect(page).to have_button 'Edit question'
            expect(page).to have_no_content question.title
            expect(page).to have_no_content question.body
            expect(page).to have_content new_question.title
            expect(page).to have_content new_question.body
          else
            nil
          end
        end
      end

      scenario 'with blank title', js: true do
        edit_question(new_titleless_question)

        page.document.synchronize seconds=20 do
          if page.has_content? "Title can't be blank"
            expect(page).to have_content "Title can't be blank"
          else
            nil
          end
        end
      end

      scenario 'with blank body', js: true do
        edit_question(new_bodyless_question)

        page.document.synchronize seconds=20 do
          if page.has_content? "Body can't be blank"
            expect(page).to have_content "Body can't be blank"
          else
            nil
          end
        end
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
