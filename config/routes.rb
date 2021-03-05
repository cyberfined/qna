Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users

  resources :questions, only: %i[index show new create] do
    resources :answers, only: %i[show new create], shallow: true
  end
end
