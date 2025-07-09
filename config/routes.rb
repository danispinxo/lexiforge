Rails.application.routes.draw do
  # Root route
  root 'source_texts#index'
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Resources
  resources :source_texts do
    collection do
      post :import_from_gutenberg
    end
    member do
      get :generate_cut_up, to: 'poems#generate_cut_up'
    end
  end
  
  resources :poems
  
  # Legacy routes for backward compatibility
  get 'poems/new'
  get 'poems/create'
  get 'poems/show'
  get 'poems/index'
  get 'source_texts/index'
  get 'source_texts/show'
end
