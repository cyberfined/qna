Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :questions, only: %i[index show new create] do
    resources :answers, only: %i[show new create], shallow: true
  end
end