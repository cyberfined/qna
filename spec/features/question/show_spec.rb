RSpec.feature 'User can watch a question and answers to it', %q{
  In order to see body of the question and answers to it or to write my own answer
  As an unauthenticated or authenticated user
  I'd like to watch the question's page
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }
  given!(:answers) { create_list(:answer, 3, question: question, user: user) }

  scenario "User watches the question's page" do
    visit questions_path
    click_on question.title

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    answers.each do |ans|
      expect(page).to have_content ans.body
    end
  end
end
