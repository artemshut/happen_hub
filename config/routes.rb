Rails.application.routes.draw do
  get "public_profiles/show"
  match "/500", to: "errors#server_error", via: :all
  post "accept-cookies", to: "pages#accept_cookies"
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Mobile-specific endpoint
  devise_scope :user do
    post "/users/google_mobile_login", to: "users/omniauth_callbacks#google_mobile"
  end

  get "/dashboard", to: "users#dashboard", as: :dashboard

  unauthenticated :user do
    resources :events, only: [ :index, :show ]
  end

  authenticated :user do
    get "users/search", to: "users#search", as: :search_users, defaults: { format: :turbo_stream }

    resources :friendships, only: %i[index create update destroy] do
      collection do
        get :search
      end
    end

    resource :profile do
      patch :avatar
    end

    resources :likes, only: [ :create, :destroy ]

    resources :groups do
      member do
        post :add_friend
      end
    end

    resource :profile, only: [ :show, :edit, :update ]

    resources :events do
      resources :event_suggestions, only: [ :create, :update ]
      resources :comments, only: [ :create, :update, :destroy, :edit ]

      member do
        post :add_friend
        patch :update_rsvp
        delete :file, to: "events#remove_file"
        post "invite_group/:group_id", to: "events#invite_group", as: "invite_group"
      end
    end
  end

  namespace :api do
    resources :events, only: [ :index ]

    namespace :v1 do
      resources :sessions, only: [ :create, :destroy ]
      resources :events, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          post :rsvp, to: "events#update_rsvp"
        end
      end
      resources :event_categories, only: [ :index, :show ]
      resources :groups, only: [ :index, :show, :create, :update, :destroy ]
      resources :users, only: [ :show ] do
        collection do
          post :fcm_token, to: "users#update_fcm_token"
        end
      end

      post "tokens/refresh", to: "tokens#refresh"
      get "me", to: "users#me"
    end
  end

  # Root route
  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # config/routes.rb
  get "/u/:username", to: "public_profiles#show", as: :public_profile
  post "/u/:username/friend_request", to: "public_profiles#add_friend", as: :send_friend_request
end
