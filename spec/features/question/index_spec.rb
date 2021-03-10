RSpec.feature 'User can watch all questions', %q{
  In order to help people with their questions or find questions that interesting for me
  As an unauthenticated or authenticated user
  I'd like to watch all questions
} do
  given!(:user) { create(:user) }
  given!(:questions) { create_list(:question, 3, user: user) }

  scenario 'User watches all questions' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end
end
