Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :source_texts do
        collection do
          post :import_from_gutenberg
        end
        member do
          post :generate_cut_up, to: 'poems#generate_cut_up'
        end
      end
      
      resources :poems
    end
  end

  # Handle preflight OPTIONS requests for CORS
  match '*path', to: 'application#handle_options_request', via: :options
end
