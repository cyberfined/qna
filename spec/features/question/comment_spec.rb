RSpec.feature 'User can create a comment to the question', %q{
  In order to express my opinion about the question
  As an authenticated user
  I'd like to comment it
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }

  def post_comment(comment)
    within '.comment-form' do
      fill_in 'Body', with: comment.body
      click_on 'Comment'
    end
  end

  describe 'Authenticated user', js: true do
    given(:comment) { build(:comment) }
    given(:invalid_comment) { build(:comment, :invalid) }

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

  describe 'Unauthenticated user' do
    scenario 'tries to create a comment' do
      visit question_path(question)

      expect(page).to have_no_css '.comment-form'
      expect(page).to have_no_button 'Comment'
    end
  end
end
