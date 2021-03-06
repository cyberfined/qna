RSpec.feature 'User can watch all questions', %q{
  In order to help people with their questions or find questions that interesting for me
  As an unauthenticated or authenticated user
  I'd like to watch all questions
} do
  given!(:questions) do
    # TODO: use faker to randomize questions in factory
    Question.create!([{ title: 'Question1', body: 'Body1' },
                      { title: 'Question2', body: 'Body2' },
                      { title: 'Question3', body: 'Body3' }])
  end

  scenario 'User watches all questions' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end
end
