Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'admin/dashboard#index'

  namespace :api do
    devise_for :users, controllers: {
      sessions: 'api/sessions',
      registrations: 'api/registrations'
    }, skip: %i[passwords confirmations unlocks]

    resources :source_texts do
      collection do
        post :import_from_gutenberg
      end
      member do
        post :generate_poem, to: 'poems#generate_poem'
      end
    end

    resources :poems
    get 'user/current', to: 'users#current_user_info'
    put 'user/profile', to: 'users#update_profile'
    put 'user/password', to: 'users#change_password'
  end

  match '*path', to: 'application#handle_options_request', via: :options
end
