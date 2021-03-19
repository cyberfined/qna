RSpec.feature "User can vote for or against another user's question", %q{
  In order to show my approval or disapproval to a question
  As an authenticated user
  I'd like to vote for or against it
} do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }

    background { sign_in(user) }

    context "votes for/against another user's question: ", js: true do
      given!(:another_user) { create(:user) }
      given!(:question) { another_user.questions.create!(attributes_for(:question)) }

      background do
        visit question_path(question)
        within '.rating' do
          expect(page).to have_content '0'
        end
        expect(page.find_link('Vote for')[:disabled]).to be_falsey
        expect(page.find_link('Vote against')[:disabled]).to be_falsey
      end

      scenario 'votes for' do
        click_on 'Vote for'

        within '.rating' do
          expect(page).to have_content '1'
        end
        expect(page.find_link('Vote for')[:disabled]).to_not be_falsey
        expect(page.find_link('Vote against')[:disabled]).to be_falsey
      end

      scenario 'votes against' do
        click_on 'Vote against'

        within '.rating' do
          expect(page).to have_content '-1'
        end
        expect(page.find_link('Vote for')[:disabled]).to be_falsey
        expect(page.find_link('Vote against')[:disabled]).to_not be_falsey
      end

      scenario 'changes for to against' do
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

      scenario 'changes against to for' do
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

    scenario 'tries to vote for/against his question' do
      question = user.questions.create!(attributes_for(:question))
      visit question_path(question)

      within '.rating' do
        expect(page).to have_content '0'
      end
      expect(page).to have_no_link 'Vote for'
      expect(page).to have_no_link 'Vote against'
    end
  end

  describe 'Unauthenticated user' do
    scenario 'tries to vote for/against a question' do
      question = create(:user).questions.create!(attributes_for(:question))
      visit question_path(question)

      within '.rating' do
        expect(page).to have_content '0'
      end
      expect(page).to have_no_link 'Vote for'
      expect(page).to have_no_link 'Vote against'
    end
  end
end
