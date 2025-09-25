Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'up' => 'rails/health#show', as: :rails_health_check
  post 'csp-violation-report-endpoint', to: 'csp_violations#create'

  root 'admin/dashboard#index'

  namespace :api do
    devise_for :users, controllers: {
      sessions: 'api/sessions',
      registrations: 'api/registrations'
    }, skip: %i[passwords confirmations unlocks]

    resources :source_texts do
      collection do
        post :import_from_gutenberg
        post :create_custom
        get :my_source_texts
      end
      member do
        post :generate_poem, to: 'poems#generate_poem'
        get :download
        put :update
      end
    end

    resources :poems do
      collection do
        get :my_poems
      end
      member do
        get :download
      end
    end
    get 'user/current', to: 'users#current_user_info'
    put 'user/profile', to: 'users#update_profile'
    put 'user/password', to: 'users#change_password'
    get 'users', to: 'users#index'
  end

  match '*path', to: 'application#handle_options_request', via: :options
end
