Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users

  resources :questions, except: :edit do
    resources :answers, only: %i[create destroy], shallow: true
  end
end
