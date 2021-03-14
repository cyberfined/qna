RSpec.feature 'User can delete attachment from his question', %q{
  In order to remove unneeded content from my question
  As an authenticated user
  I'd like to delete an attachment
} do
  describe 'Authenticated user' do
    given!(:user) { create(:user) }
    given(:another_user) { create(:user) }

    background { sign_in(user) }

    scenario 'removes an attachment from his question', js: true do
      question = user.questions.create!(attributes_for(:question))
      question.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                            filename: '403.html')
      visit questions_path
      click_on question.title

      within '.question-files' do
        expect(page).to have_link '403.html'
        click_on 'Delete attachment'
        expect(page).to have_no_link '403.html'
      end
    end

    scenario "tries to remove an attachment from another user's question" do
      question = another_user.questions.create!(attributes_for(:question))
      question.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                            filename: '403.html')

      visit questions_path
      click_on question.title

      within '.question-files' do
        expect(page).to have_link '403.html'
        expect(page).to have_no_button 'Delete attachment'
      end
    end
  end

  describe 'Unauthenticated user' do
    given!(:user) { create(:user) }
    given!(:question) { user.questions.create!(attributes_for(:question)) }

    scenario 'tries to remove an attachment' do
      question.files.attach(io: File.open(Rails.root.join(Rails.public_path, '403.html')),
                            filename: '403.html')
      visit questions_path
      click_on question.title

      within '.question-files' do
        expect(page).to have_link '403.html'
        expect(page).to have_no_button 'Delete attachment'
      end
    end
  end
end
