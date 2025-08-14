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
        post :generate_cut_up, to: 'poems#generate_cut_up'
        post :generate_erasure, to: 'poems#generate_erasure'
        post :generate_snowball, to: 'poems#generate_snowball'
        post :generate_mesostic, to: 'poems#generate_mesostic'
        post :generate_n_plus_seven, to: 'poems#generate_n_plus_seven'
        post :generate_definitional, to: 'poems#generate_definitional'
        post :generate_found_poem, to: 'poems#generate_found_poem'
      end
    end

    resources :poems
    get 'user/current', to: 'users#current_user_info'
  end

  match '*path', to: 'application#handle_options_request', via: :options
end
