RSpec.feature 'User can select the best answer to his question', %q{
  In order to mark right answer to my question for other users
  As an authenticated user
  I'd like to select the best answer to my question
} do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }

    background { sign_in(user) }

    context 'interacts with his question: ' do 
      given!(:question) { user.questions.create!(attributes_for(:question)) }
      given!(:answers) { create_list(:answer, 2, user: user, question: question) }

      background do
        visit questions_path
        click_on question.title

        answers.each do |ans|
          fill_in 'Body', with: ans.body
          click_on 'Answer'
        end
      end

      def mark_best(answer)
        answer_selector = ".answer[data-id='#{answer.id}']" 

        within answer_selector do
          click_on 'Mark best'

          expect(page).to have_no_button 'Mark best'
        end

        expect(page.find('.best-answer'))
        page.all('.answer').each.with_index do |ans, ind|
          next if ind == 0

          expect(ans).to have_button 'Mark best'
        end
      end

      scenario 'selects the best answer to his question', js: true do
        mark_best(answers.last)
        
        expect(page.find('.answer p', match: :first).text).to eq answers.last.body
      end
      
      scenario 'changes the best answers to his question', js: true do
        mark_best(answers.last)
        mark_best(answers.first)

        expect(page.find('.answer p', match: :first).text).to eq answers.first.body
      end

      scenario 'watches the answers to the question', js: true do
        mark_best(answers.last)
        visit current_path

        expect(page.find('.answer p', match: :first).text).to eq answers.last.body
      end
    end

    context "interacts with another user's question: " do 
      given!(:another_user) { create(:user) } 
      given!(:question) { another_user.questions.create!(attributes_for(:question)) }
      given!(:answer) { question.answers.create!(attributes_for(:answer, user: another_user)) }

      scenario "tries to select the best answer to another user's question" do
        visit questions_path
        click_on question.title

        expect(page).to have_no_button 'Mark best'
      end
    end
  end

  describe 'Unauthenticated user' do
    given!(:user) { create(:user) } 
    given!(:question) { user.questions.create!(attributes_for(:question)) }
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    scenario "tries to select the best answer to another user's question" do
      visit questions_path
      click_on question.title

      expect(page).to have_no_button 'Mark best'
    end
  end
end
