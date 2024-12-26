Rails.application.routes.draw do
  devise_for :users

  # Order routes
  resources :orders, only: [:show] do
    member do
      get 'checkout', to: 'orders#checkout'  # now it will trigger OrdersController#checkout
    end
  end
  

  # Product routes with checkout
  resources :products do
    member do
      get 'checkout' # This will point to the checkout action in ProductsController
      post 'checkout', to: 'products#checkout' # Adding POST method for checkout action
    end
  end

  #  post '/stripe/webhook', to: 'checkout#stripe_webhook'
 post 'stripe/webhook', to: 'stripe#webhook'


  # Root route
  root "products#index"
  
  # Additional routes
  get "home/about"
  get "up" => "rails/health#show", as: :rails_health_check
end
