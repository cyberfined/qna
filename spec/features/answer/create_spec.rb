RSpec.feature 'User can give answer to a question', %q{
  In order to help someone with his question
  As an authenticated user
  I'd like to give an answer
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }

  def post_answer(answer)
    fill_in 'Body', with: answer.body
    click_on 'Answer'
  end

  describe 'Authenticated user', js: true do
    given(:answer) { build(:answer) }
    given(:bodyless_answer) { build(:answer, :bodyless) }

    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'answers to the question' do
      post_answer(answer)

      within '.answers' do
        expect(page).to have_content answer.body
      end
    end

    scenario 'tries to create answer with blank body' do
      post_answer(bodyless_answer)

      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries to post an answer' do
    visit question_path(question)

    expect(page).to have_no_field('Body')
    expect(page).to have_no_button('Answer')
  end
end
