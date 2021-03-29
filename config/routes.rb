Rails.application.routes.draw do
  root to: 'questions#index'

  use_doorkeeper

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

    resources :subscriptions, only: %i[create destroy], shallow: true
  end

  namespace :api do
    namespace :v1 do
      resources :profiles, only: :index do
        get :me, on: :collection
      end

      resources :questions, except: %i[new edit] do
        resources :answers, shallow: true, except: %i[new edit]
      end
    end
  end

  resources :comments, only: :create

  resources :rewards, only: :index

  resources :attachments, only: :destroy
end
