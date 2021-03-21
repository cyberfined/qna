RSpec.feature "User can vote for or against another user's answer", %q{
  In order to show my approval or disapproval to an answer 
  As an authenticated user
  I'd like to vote for or against it
} do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }
    given!(:another_user) { create(:user) }
    given!(:question) { another_user.questions.create!(attributes_for(:question)) }

    background { sign_in(user) }

    context "votes for/against another user's answer: ", js: true do
      given!(:answer) { question.answers.create!(attributes_for(:answer, user: another_user)) }

      background do
        visit question_path(question)
        within '.answers' do
          within '.rating' do
            expect(page).to have_content '0'
          end
          expect(page.find_link('Vote for')[:disabled]).to be_falsey
          expect(page.find_link('Vote against')[:disabled]).to be_falsey
        end
      end

      scenario 'votes for' do
        within '.answers' do
          click_on 'Vote for'

          within '.rating' do
            expect(page).to have_content '1'
          end
          expect(page.find_link('Vote for')[:disabled]).to_not be_falsey
          expect(page.find_link('Vote against')[:disabled]).to be_falsey
          page.refresh
          expect(page.find_link('Vote for')[:disabled]).to_not be_falsey
          expect(page.find_link('Vote against')[:disabled]).to be_falsey
        end
      end

      scenario 'votes against' do
        within '.answers' do
          click_on 'Vote against'

          within '.rating' do
            expect(page).to have_content '-1'
          end
          expect(page.find_link('Vote for')[:disabled]).to be_falsey
          expect(page.find_link('Vote against')[:disabled]).to_not be_falsey
          page.refresh
          expect(page.find_link('Vote for')[:disabled]).to be_falsey
          expect(page.find_link('Vote against')[:disabled]).to_not be_falsey
        end
      end

      scenario 'changes for to against' do
        within '.answers' do
          click_on 'Vote for'
          within '.rating' do
            expect(page).to have_content '1'
          end
          expect(page.find_link('Vote for')[:disabled]).to_not be_falsey

          click_on 'Vote against'
          within '.rating' do
            expect(page).to have_content '0'
          end
          expect(page.find_link('Vote for')[:disabled]).to be_falsey

          click_on 'Vote against'
          within '.rating' do
            expect(page).to have_content '-1'
          end
          expect(page.find_link('Vote for')[:disabled]).to be_falsey
          expect(page.find_link('Vote against')[:disabled]).to_not be_falsey
        end
      end

      scenario 'changes against to for' do
        within '.answers' do
          click_on 'Vote against'
          within '.rating' do
            expect(page).to have_content '-1'
          end
          expect(page.find_link('Vote against')[:disabled]).to_not be_falsey

          click_on 'Vote for'
          within '.rating' do
            expect(page).to have_content '0'
          end
          expect(page.find_link('Vote against')[:disabled]).to be_falsey

          click_on 'Vote for'
          within '.rating' do
            expect(page).to have_content '1'
          end
          expect(page.find_link('Vote for')[:disabled]).to_not be_falsey
          expect(page.find_link('Vote against')[:disabled]).to be_falsey
        end
      end
    end

    scenario 'tries to vote for/against his answer' do
      question.answers.create!(attributes_for(:answer, user: user))
      visit question_path(question)

      within '.answers' do
        within '.rating' do
          expect(page).to have_content '0'
        end
        expect(page).to have_no_link 'Vote for'
        expect(page).to have_no_link 'Vote against'
      end
    end
  end

  describe 'Unauthenticated user' do
    given!(:user) { create(:user) }
    given!(:question) { user.questions.create!(attributes_for(:question)) }
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    scenario 'tries to vote for/against his answer' do
      visit question_path(question)

      within '.answers .rating' do
        expect(page).to have_content '0'
      end
      expect(page).to have_no_link 'Vote for'
      expect(page).to have_no_link 'Vote against'
    end
  end
end
