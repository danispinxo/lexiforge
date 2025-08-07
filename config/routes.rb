Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    resources :source_texts do
      collection do
        post :import_from_gutenberg
      end
      member do
        post :generate_cut_up, to: 'poems#generate_cut_up'
        post :generate_erasure, to: 'poems#generate_erasure'
        post :generate_snowball, to: 'poems#generate_snowball'
        post :generate_mesostic, to: 'poems#generate_mesostic'
      end
    end

    resources :poems
  end

  match '*path', to: 'application#handle_options_request', via: :options
end
