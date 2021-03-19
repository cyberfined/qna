Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users

  resources :questions, except: :edit do
    member do
      post :vote_for
      post :vote_against
    end

    resources :answers, only: %i[create update destroy], shallow: true do
      member do
        post :mark_best
        post :vote_for
        post :vote_against
      end
    end
  end

  delete '/attachments/:id', to: 'attachments#destroy', as: 'attachment'
  get '/rewards', to: 'rewards#index', as: 'rewards'
end
