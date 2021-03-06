Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users

  resources :questions, only: %i[index show new create destroy] do
    resources :answers, only: :create, shallow: true
  end
end
