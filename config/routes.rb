Rails.application.routes.draw do
  get 'poems/new'
  get 'poems/create'
  get 'poems/show'
  get 'poems/index'
  get 'source_texts/index'
  get 'source_texts/show'
  get "up" => "rails/health#show", as: :rails_health_check

  resources :source_texts do
    collection do
      post :import_from_gutenberg
    end
    get 'generate_cut_up', to: 'poems#generate_cut_up'
  end
  resources :poems
end
