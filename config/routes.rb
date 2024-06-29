Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :test, only: %i[index]
      resources :phrases
      resources :tags
      resources :questions, only: %i[show]

      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registrations'
      }

      namespace :auth do
        resources :sessions, only: %i[index]
      end

      # resources :users do
      #   resources :phrases, only: [:index]
      # end
    end
  end
end

