Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root "articles#index", as: :authenticated_root
  end

  root "pages#landing"

  resources :articles, except: [:new] do
    collection do
      get :new_upload, path: "new"
      post :generate
    end
    member do
      get :regenerate
      post :regenerate, action: :do_regenerate
      get :versions
    end
  end
end
