Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post 'signup', to: 'auths#signup'
      post 'signin', to: 'auths#signin'
      resources :users, only: [:show, :update]
      resources :feedbacks, only: [:create]
      resources :products, only: [:index, :show]
      resources :reward_applications, only: [:create, :index]
      post 'admin/signin', to: 'admin_auths#signin'
      get 'admin/stats', to: 'admin#stats'
      get 'admin/users', to: 'admin#users'
      get 'admin/feedbacks', to: 'admin#feedbacks'
      put 'admin/users/:id', to: 'admin#update_user'
      delete 'admin/users/:id', to: 'admin#destroy_user'
      get 'admin/reward_requests', to: 'admin#reward_requests'
      put 'admin/reward_requests/:id', to: 'admin#update_reward_request'
      post 'admin/receipts', to: 'admin#create_receipt'
      post 'admin/receipts/import_csv', to: 'admin#import_receipts'
      get 'admin/products', to: 'admin#products'
      post 'admin/products/import_csv', to: 'admin#import_csv'
      post 'admin/products', to: 'admin#create_product'
      put 'admin/products/:id', to: 'admin#update_product'
      delete 'admin/products/:id', to: 'admin#destroy_product'
      # Slider routes
      get 'sliders', to: 'sliders#index'
      get 'admin/sliders', to: 'admin#slider_images'
      post 'admin/sliders', to: 'admin#create_slider_image'
      delete 'admin/sliders/:id', to: 'admin#destroy_slider_image'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
