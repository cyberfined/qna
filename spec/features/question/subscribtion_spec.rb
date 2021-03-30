RSpec.feature 'User can subscribe on or unsubscribe from a question', %q{
  In order to receiving/stop receiving notifications about new answers
  As an authenticated user
  I'd like to subscribe on/unsubscribe from a question
} do
  given!(:user) { create(:user) }
  given!(:question) { create(:user).questions.create!(attributes_for(:question)) }

  describe 'Authenticated user' do
    given(:new_question) { build(:question) }

    background { sign_in(user) }

    scenario "is already subscribed on it's own question after its creation" do
      visit new_question_path
      fill_in 'Title', with: new_question.title
      fill_in 'Body', with: new_question.body
      click_on 'Ask'

      expect(page).to have_no_link 'Subscribe'
      expect(page).to have_link 'Unsubscribe'
    end

    scenario 'subscribes on a question', js: true do
      visit question_path(question)
      click_on 'Subscribe'

      expect(page).to have_no_link 'Subscribe'
      expect(page).to have_link 'Unsubscribe'
    end

    scenario 'unsubscribes from a question', js: true do
      visit question_path(question)
      click_on 'Subscribe'
      expect(page).to have_no_link 'Subscribe'
      click_on 'Unsubscribe'

      expect(page).to have_no_link 'Unsubscribe'
      expect(page).to have_link 'Subscribe'
    end
  end

  describe 'Unauthenticated user' do
    scenario "can't subscribe on a question" do
      visit question_path(question)

      expect(page).to have_no_link 'Subscribe'
      expect(page).to have_no_link 'Unsubscribe'
    end
  end
end
