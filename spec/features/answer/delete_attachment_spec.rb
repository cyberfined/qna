RSpec.feature 'User can delete attachment from his answer', %q{
  In order to remove unneeded content from my answer
  As an authenticated user
  I'd like to delete an attachment
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }

  describe 'Authenticated user' do
    given(:another_user) { create(:user) }

    background do
      sign_in(user)
      visit questions_path
    end

    scenario 'removes an attachment from his answer', js: true do
      answer = question.answers.create!(attributes_for(:answer, user: user))
      answer.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                          filename: '403.html')
      click_on question.title

      within '.answers' do
        expect(page).to have_link '403.html'
        click_on 'Delete attachment'
        expect(page).to have_no_link '403.html'
      end
    end

    scenario "tries to remove an attachment from another user's answer" do
      answer = question.answers.create!(attributes_for(:answer, user: another_user))
      answer.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                          filename: '403.html')
      click_on question.title

      within '.answers' do
        expect(page).to have_link '403.html'
        expect(page).to have_no_button 'Delete attachment'
      end
    end
  end

  describe 'Unauthenticated user' do
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }

    scenario 'tries to remove an attachment' do
      answer.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                          filename: '403.html')
      visit questions_path
      click_on question.title

      within '.answers' do
        expect(page).to have_link '403.html'
        expect(page).to have_no_button 'Delete attachment'
      end
    end
  end
end
