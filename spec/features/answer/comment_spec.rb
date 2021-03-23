RSpec.feature 'User can create a comment to the answer', %q{
  In order to express my opinion about the answer
  As an authenticated user
  I'd like to comment it
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }
  given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }
  given(:comment) { build(:comment) }
  given(:invalid_comment) { build(:comment, :invalid) }

  def post_comment(comment)
    within '.comment-form-Answer' do
      fill_in 'Body', with: comment.body
      click_on 'Comment'
    end
  end

  describe 'Authenticated user', js: true do
    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'creates a comment' do
      post_comment(comment)

      expect(page).to have_content "#{user.email}:#{comment.body}"
    end

    scenario 'tries to create a comment with errors' do
      post_comment(invalid_comment)

      expect(page).to have_content "Body can't be blank"
    end
  end

  describe 'Multisession', js: true do
    scenario 'appends new comment to the answer' do
      using_session('another_user') do
        visit question_path(question)
      end

      using_session('user') do
        sign_in(user)
        visit question_path(question)
        post_comment(comment)
      end

      using_session('another_user') do
        expect(page).to have_content "#{user.email}:#{comment.body}"
      end
    end
  end

  describe 'Unauthenticated user' do
    scenario 'tries to create a comment' do
      visit question_path(question)

      expect(page).to have_no_css '.comment-form'
      expect(page).to have_no_css '.comment-form-Answer'
      expect(page).to have_no_button 'Comment'
    end
  end
end
