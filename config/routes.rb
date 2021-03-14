Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users

  resources :questions, except: :edit do
    resources :answers, only: %i[create update destroy], shallow: true do
      member do
        post :mark_best
      end
    end
  end

  delete '/attachments/:id', to: 'attachments#destroy', as: 'attachment'
end
