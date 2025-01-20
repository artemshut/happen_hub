Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get '/users/sign_out', to: 'devise/sessions#destroy'
  end

  authenticated :user do
    get '/dashboard', to: 'users#dashboard', as: :dashboard
    get '/profile/edit', to: 'users#edit', as: :edit_profile
    patch '/profile', to: 'users#update', as: :update_profile

    resources :friendships, only: %i[index create update]

    resources :groups do
      member do
        post :add_friend
      end
    end

    resources :events do
      member do
        post :add_friend
        patch :update_rsvp
      end
    end
  end

  namespace :api do
    resources :events, only: [:index]
  end

  # Root route
  root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
