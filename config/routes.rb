Rails.application.routes.draw do
  devise_for :users

  # Order routes
  resources :orders, only: [ :show ] do
    member do
      get "checkout", to: "orders#checkout"
    end
  end

  # Product routes with checkout
  resources :products do
    member do
      get "checkout"
      post "checkout", to: "products#checkout"
    end

    collection do
      get "thank_you", to: "products#thank_you"
    end


    resource :wishlist, only: [ :create, :destroy ]
  end

  post "stripe/webhook", to: "stripe#webhook"
  root "products#index"
  resources :wishlists, only: [ :index ]
  get "home/about"
  get "up" => "rails/health#show", as: :rails_health_check
end
