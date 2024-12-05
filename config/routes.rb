Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get "/help", to: 'static_pages#help', as: 'help'
  get "/about", to: 'static_pages#about', as: 'about'
  get "/contact", to: 'static_pages#contact', as: 'contact'
  get "/signup", to: "users#new"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to:"sessions#destroy"

  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:edit, :create, :new, :update]
  #ホームページのコントローラー経由で実行されるので、newやeditのようなアクションは不要
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  get '/microposts', to: 'static_pages#home'
end
