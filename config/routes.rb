Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :source_texts do
        collection do
          post :import_from_gutenberg
        end
        member do
          post :generate_cut_up, to: 'poems#generate_cut_up'
          post :generate_erasure, to: 'poems#generate_erasure'
        end
      end
      
      resources :poems
    end
  end

  match '*path', to: 'application#handle_options_request', via: :options
end
