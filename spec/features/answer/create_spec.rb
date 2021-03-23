RSpec.feature 'User can give answer to a question', %q{
  In order to help someone with his question
  As an authenticated user
  I'd like to give an answer
} do
  given!(:user) { create(:user) }
  given!(:question) { user.questions.create!(attributes_for(:question)) }
  given(:files) {[ Rails.root.join(Rails.public_path, '403.html'),
                   Rails.root.join(Rails.public_path, '404.html') ]}

  def post_answer(answer, files=[], link=nil)
    fill_in 'Body', with: answer.body
    attach_file 'Files', files unless files.empty?
    unless link.nil?
      within '.create-answer-form' do
        click_on 'Add link'
        fill_in 'Link title', with: link.title
        fill_in 'Link url', with: link.url
      end
    end
    click_on 'Answer'
  end

  describe 'Authenticated user', js: true do
    given(:answer) { build(:answer) }
    given(:bodyless_answer) { build(:answer, :bodyless) }

    background do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'answers to the question' do
      post_answer(answer)

      within '.answers' do
        expect(page).to have_content answer.body
      end
    end

    scenario 'answers to the question with files attachment' do
      post_answer(answer, files)

      within '.answers' do
        expect(page).to have_content answer.body
        expect(page).to have_link '403.html'
        expect(page).to have_link '404.html'
      end
    end

    scenario 'tries to create answer with blank body' do
      post_answer(bodyless_answer)

      expect(page).to have_content "Body can't be blank"
    end
  end

  describe 'Multisession', js: true do
    given(:answer) { build(:answer) }
    given(:link) { Link.new(title: 'google', url: 'https://google.com') }
    given(:gist_link) { Link.new(title: 'gist', url: 'https://gist.github.com/cyberfined/3263456890e06a904ac504961322118c') }

    scenario 'appends new answer' do
      another_user = create(:user)
      using_session('another_user') do
        sign_in(another_user)
        visit question_path(question)
      end

      using_session('user') do
        sign_in(user)
        visit question_path(question)
        post_answer(answer, files, link)
      end

      using_session('another_user') do
        within '.answers' do
          expect(page).to have_content answer.body
          expect(page).to have_content 'Rating: 0'
          expect(page).to have_link 'Vote for'
          expect(page).to have_link 'Vote against'
          expect(page).to have_link link.title, href: link.url
          expect(page).to have_link '403.html'
          expect(page).to have_link '403.html'
          expect(page).to have_no_button 'Mark best'
        end
      end
    end

    scenario 'appends new answer with gist link' do
      another_user = create(:user)
      using_session('another_user') do
        sign_in(another_user)
        visit question_path(question)
      end

      using_session('user') do
        sign_in(user)
        visit question_path(question)
        post_answer(answer, files, gist_link)
      end

      using_session('another_user') do
        within '.answers' do
          expect(page).to have_content answer.body
          expect(page).to have_content 'Rating: 0'
          expect(page).to have_link 'Vote for'
          expect(page).to have_link 'Vote against'
          expect(page).to have_content 'Test file 1'
          expect(page).to have_content 'Test content 1'
          expect(page).to have_content 'Test file 2'
          expect(page).to have_content 'Test content 2'
          expect(page).to have_link '403.html'
          expect(page).to have_link '403.html'
          expect(page).to have_no_button 'Mark best'
        end
      end
    end

    scenario 'appends new answer to unauthenticated user' do
      using_session('unauth_user') do
        visit question_path(question)
      end

      using_session('user') do
        sign_in(user)
        visit question_path(question)
        post_answer(answer, files, link)
      end

      using_session('unauth_user') do
        within '.answers' do
          expect(page).to have_content answer.body
          expect(page).to have_content 'Rating: 0'
          expect(page).to have_no_link 'Vote for'
          expect(page).to have_no_link 'Vote against'
          expect(page).to have_link link.title, href: link.url
          expect(page).to have_link '403.html'
          expect(page).to have_link '403.html'
          expect(page).to have_no_button 'Mark best'
        end
      end
    end
  end

  scenario 'Unauthenticated user tries to post an answer' do
    visit question_path(question)

    expect(page).to have_no_field('Body')
    expect(page).to have_no_button('Answer')
  end
end
