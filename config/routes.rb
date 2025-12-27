Rails.application.routes.draw do
  
  root "home_page#index"

  get "home_page/index"

  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "register", to: "users#new"

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  resources :bids, only: %i[index]

  resources :users, except: %i[new]

  resources :items, except: %i[show] do
    resources :bids, only: %i[new create]
  end

  # Catch-all route 
  match "*path", to: "errors#not_found", via: :all
end
