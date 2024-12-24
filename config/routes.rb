Rails.application.routes.draw do
  devise_for :users
  resources :products
  # get "home/index"  
  get "home/about"
  root "products#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
