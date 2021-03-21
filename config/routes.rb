Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users

  concern :votable do
    member do
      post :vote_for
      post :vote_against
    end
  end

  resources :questions, except: :edit, concerns: :votable do
    resources :answers, only: %i[create update destroy], concerns: :votable, shallow: true do
      member do
        post :mark_best
      end
    end
  end

  delete '/attachments/:id', to: 'attachments#destroy', as: 'attachment'
  get '/rewards', to: 'rewards#index', as: 'rewards'
end
