Rails.application.routes.draw do

  get "public/index"

  devise_for :users

  # The Nela protocol endpoints
  namespace :nela do
    resources :messages, only: [:create] do
      resources :handshakes, only: [:update]
    end
  end  

  # The client application
  resources :conversations do
    resources :messages, only: [:create, :destroy] do
      member do
        get "reply"
      end
    end
  end

  get "up"             => "rails/health#show",        as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"       => "rails/pwa#manifest",       as: :pwa_manifest

  root "public#index"

end
