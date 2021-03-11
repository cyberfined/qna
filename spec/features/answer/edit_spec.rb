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

        page.document.synchronize seconds=20 do
          if page.has_css? '.answers'
            within '.answers' do
              expect(page).to have_no_field 'answer[body]'
              expect(page).to have_no_button 'Update answer'
            end
          else
            nil
          end
        end

        fill_in 'answer[body]', with: answer.body
        click_on 'Answer'

        within '.answers' do
          page.document.synchronize seconds=20 do
            if page.has_content? answer.body
              expect(page).to have_content answer.body
            else
              nil
            end
          end
        end
      end

      def edit_answer(new_answer)
        click_on 'Edit answer'

        page.document.synchronize do
          within '.answers' do
            if page.has_field? 'answer[body]'
              fill_in 'answer[body]', with: new_answer.body
              click_on 'Update answer'
            else
              nil
            end
          end
        end
      end

      scenario 'without errors' do
        edit_answer(new_valid_answer)

        within '.answers' do
          page.document.synchronize seconds=20 do
            if page.has_no_field? 'answer[body]'
                expect(page).to have_no_field 'answer[body]'
                expect(page).to have_no_button 'Update answer'
                expect(page).to have_button 'Edit answer'
                expect(page).to have_no_content answer.body
                expect(page).to have_content new_valid_answer.body
            else
              nil
            end
          end
        end
      end

      scenario 'with blank body' do
        edit_answer(new_bodyless_answer)

        page.document.synchronize seconds=20 do
          if page.has_content? "Body can't be blank"
            expect(page).to have_content "Body can't be blank"
          else
            nil
          end
        end
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
