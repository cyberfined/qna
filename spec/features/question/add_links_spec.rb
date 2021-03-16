RSpec.feature 'User can add links to his question on creation', %q{
  In order to provide additional information to my question
  As an authenticated user
  I'd like to add links to it
} do
  describe 'Authenticated user', js: :true do
    given!(:user) { create(:user) }
    given(:question) { build(:question) }

    background do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'
    end

    def ask_question(links)
      fill_in 'Title', with: question.title
      fill_in 'Body', with: question.body

      links.each do |link|
        click_on 'Add link'
        within all('.link-form').last do
          fill_in 'Link title', with: link.title
          fill_in 'Link url', with: link.url
        end
      end

      click_on 'Ask'
    end

    scenario 'add link to his question' do
      links = [Link.new(title: 'google', url: 'https://google.com')]
      ask_question(links)

      expect(page).to have_link links.first.title, href: links.first.url
    end

    scenario 'add two links to his question' do
      links = [ Link.new(title: 'google', url: 'https://google.com'),
                Link.new(title: 'example', url: 'https://example.com') ]
      ask_question(links)

      expect(page).to have_link links.first.title, href: links.first.url
      expect(page).to have_link links.second.title, href: links.second.url
    end

    scenario 'add gist to his question' do
      links = [Link.new(title: 'gist', url: 'https://gist.github.com/cyberfined/3263456890e06a904ac504961322118c')]
      ask_question(links)

      expect(page).to have_content 'Test file 1'
      expect(page).to have_content 'Test content 1'
      expect(page).to have_content 'Test file 2'
      expect(page).to have_content 'Test content 2'
    end

    scenario 'tries to add link with blank title to his question' do
      links = [Link.new(url: 'https://google.com')]
      ask_question(links)

      expect(page).to have_content "Links title can't be blank"
    end

    scenario 'tries to add link with wrong url to his question' do
      links = [Link.new(title: 'wrong', url: 'wrong')]
      ask_question(links)

      expect(page).to have_content 'Links url is invalid'
    end
  end
end
