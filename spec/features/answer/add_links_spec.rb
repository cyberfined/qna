RSpec.feature 'User can add links to his answer on creation', %q{
  In order to provide additional information to my answer
  As an authenticated user
  I'd like to add links to it
} do
  describe 'Authenticated user', js: :true do
    given!(:user) { create(:user) }
    given!(:question) { user.questions.create!(attributes_for(:question)) }
    given(:answer) { build(:answer) }

    background do
      sign_in(user)
      visit questions_path
      click_on question.title
    end

    def post_answer(links)
      within '.create-answer-form' do
        links.each do |link|
          click_on 'Add link'
          within all('.link-form').last do
            fill_in 'Link title', with: link.title
            fill_in 'Link url', with: link.url
          end
        end

        fill_in 'Body', with: answer.body
        click_on 'Answer'
      end
    end

    scenario 'add link to his answer' do
      links = [Link.new(title: 'google', url: 'https://google.com')]
      post_answer(links)

      within '.answers' do
        expect(page).to have_link links.first.title, href: links.first.url
      end
    end

    scenario 'add two links to his answer' do
      links = [ Link.new(title: 'google', url: 'https://google.com'),
                Link.new(title: 'example', url: 'https://example.com') ]
      post_answer(links)

      within '.answers' do
        expect(page).to have_link links.first.title, href: links.first.url
        expect(page).to have_link links.second.title, href: links.second.url
      end
    end

    scenario 'add gist to his answer' do
      links = [Link.new(title: 'gist', url: 'https://gist.github.com/cyberfined/3263456890e06a904ac504961322118c')]
      post_answer(links)

      within '.answers' do
        expect(page).to have_content 'Test file 1'
        expect(page).to have_content 'Test content 1'
        expect(page).to have_content 'Test file 2'
        expect(page).to have_content 'Test content 2'
      end
    end

    scenario 'tries to add link with blank title to his answer' do
      links = [Link.new(url: 'https://google.com')]
      post_answer(links)

      expect(page).to have_content "Links title can't be blank"
    end

    scenario 'tries to add link with wrong url to his answer' do
      links = [Link.new(title: 'wrong', url: 'wrong')]
      post_answer(links)

      expect(page).to have_content 'Links url is invalid'
    end
  end
end
