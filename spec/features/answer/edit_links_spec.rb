RSpec.feature 'User can edit links attached to his answer', %q{
  In order to correct links attached to my answer
  As an authenticated user
  I'd like to edit links attached to it
} do
  describe 'Authenticated user', js: :true do
    given!(:user) { create(:user) }
    given!(:question) { user.questions.create!(attributes_for(:question)) }
    given!(:answer) { question.answers.create!(attributes_for(:answer, user: user)) }
    given(:link) { Link.new(title: 'google', url: 'https://google.com') }
    given(:new_valid_link) { Link.new(title: 'example', url: 'https://example.com') }
    given(:new_gist_link) { Link.new(title: 'gist', url: 'https://gist.github.com/cyberfined/3263456890e06a904ac504961322118c') }
    given(:titleless_link) { Link.new(url: 'https://google.com') }
    given(:urlless_link) { Link.new(title: 'google') }

    background do
      sign_in(user)
      visit questions_path
      click_on question.title
      click_on 'Edit answer'
      within '.answers' do
        click_on 'Add link'
      end
      attach_link(link)
      click_on 'Edit answer'
    end

    def attach_link(link)
      within all('.link-form').last do
        fill_in 'Link title', with: link.title
        fill_in 'Link url', with: link.url
      end
      click_on 'Update answer'
    end

    scenario 'edits link' do
      attach_link(new_valid_link)

      within '.answers' do
        expect(page).to have_no_link link.title
        expect(page).to have_link new_valid_link.title, href: new_valid_link.url
      end
    end

    scenario 'edits link and attaches a gist' do
      attach_link(new_gist_link)

      within '.answers' do
        expect(page).to have_no_link link.title
        expect(page).to have_content 'Test file 1'
        expect(page).to have_content 'Test content 1'
        expect(page).to have_content 'Test file 2'
        expect(page).to have_content 'Test content 2'
      end
    end

    scenario 'attaches a new link' do
      within '.answers' do
        click_on 'Add link'
      end
      attach_link(new_valid_link)

      within '.answers' do
        expect(page).to have_link link.title
        expect(page).to have_link new_valid_link.title, href: new_valid_link.url
      end
    end

    scenario 'deletes a link' do
      click_on 'Delete link'
      click_on 'Update answer'

      within '.answers' do
        expect(page).to have_no_link link.title
      end
    end

    scenario 'tries to edit link with blank title' do
      attach_link(titleless_link)

      expect(page).to have_content "Links title can't be blank"
    end

    scenario 'tries to edit link with wrong url' do
      attach_link(urlless_link)

      expect(page).to have_content 'Links url is invalid'
    end
  end
end
