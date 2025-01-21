Rails.application.routes.draw do
  devise_for :users

  resources :orders, only: [:show, :create] do
    member do
      post :checkout
      patch :fulfill
    end
    get 'orders/last', to: 'orders#show', as: :last_order
  end

  resources :reviews do
    resources :comments, only: [:create, :destroy]
    post 'like', on: :member
  end


  resources :products do
    resources :reviews, only: [:index, :show, :create, :update, :destroy] do
      resources :comments, only: [:create, :destroy]
    end
    member do
      get "checkout"
      post "checkout", to: "products#checkout"
    end
    collection do
      get "thank_you", to: "products#thank_you"
      get "search"
    end
    resource :wishlist, only: [:create, :destroy]
  end
  
  post "stripe/webhook", to: "stripe#webhook"
  root "products#index"
  resources :wishlists, only: [:index]
  get "home/about"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'user_management', to: 'dashboard#user_management'

    resources :orders, only: [:index, :show] do
      member do
        patch :fulfill
        patch :out_for_delivery
        patch :delivered
      end
    end

    resources :users, only: [:index, :show, :destroy] do
      member do
        patch :make_admin
      end
    end
  end
end
