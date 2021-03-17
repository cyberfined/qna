RSpec.feature 'User is rewarded if his answer will be the best', %q{
  In order to motivate another user's to answer on my question
  As an authenticated user
  I'd like to create a reward which will be given to the best answerer
} do
  describe 'Authenticated user', js: true do
    RewardInfo = Struct.new(:title, :picture)

    given!(:user) { create(:user) }
    given(:question) { build(:question) }
    given(:answer) { build(:answer) }
    given(:another_answer) { build(:answer) }
    given(:valid_reward) { RewardInfo.new('reward', Rails.root.join('spec', 'miscs', 'reward.png')) }
    given(:titleless_reward) { RewardInfo.new(nil, Rails.root.join('spec', 'miscs', 'reward.png')) }
    given(:pictureless_reward) { RewardInfo.new('reward', nil) }
    given(:invalid_file_reward) { RewardInfo.new('reward', Rails.root.join('public', '403.html')) }

    background do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'
    end

    def ask_question_with_reward(reward)
      fill_in 'Title', with: question.title
      fill_in 'Body', with: question.body
      fill_in 'Reward title', with: reward.title
      attach_file 'Reward picture', reward.picture unless reward.picture.nil?
      click_on 'Ask'
    end

    def post_answer(answer)
      fill_in 'Body', with: answer.body
      click_on 'Answer'
    end

    scenario 'gives reward to the first answerer' do
      ask_question_with_reward(valid_reward)
      post_answer(answer)
      click_on 'Mark best'
      visit rewards_path

      expect(page).to have_content question.title
      expect(page).to have_content valid_reward.title
      expect(page).to have_css '.reward-image'
    end

    scenario 'changes rewarded answerer from the first to the second one' do
      another_user = create(:user)

      ask_question_with_reward(valid_reward)
      post_answer(answer)
      click_on 'Mark best'
      visit rewards_path
      expect(page).to have_content question.title
      expect(page).to have_content valid_reward.title
      expect(page).to have_css '.reward-image'
      click_on 'Sign out'

      sign_in(another_user)
      visit questions_path
      click_on question.title
      post_answer(another_answer)
      click_on 'Sign out'

      sign_in(user)
      visit questions_path
      click_on question.title
      within all('.answers').last do
        click_on 'Mark best'
      end
      visit rewards_path
      expect(page).to have_no_content question.title
      expect(page).to have_no_content valid_reward.title
      expect(page).to have_no_css '.reward-image'
      click_on 'Sign out'

      sign_in(another_user)
      visit rewards_path
      expect(page).to have_content question.title
      expect(page).to have_content valid_reward.title
      expect(page).to have_css '.reward-image'
    end

    scenario 'tries to create reward with blank title' do
      ask_question_with_reward(titleless_reward)
      
      expect(page).to have_content "Reward title can't be blank"
    end

    scenario 'tries to create reward without file' do
      ask_question_with_reward(pictureless_reward)

      expect(page).to have_content 'Reward picture must be attached'
    end

    scenario 'tries to create reward with wrong file type' do
      ask_question_with_reward(invalid_file_reward)

      expect(page).to have_content 'Reward picture must be an image'
    end
  end
end
