Rails.application.routes.draw do
  root 'static_pages#home'
  get "/help", to: 'static_pages#help', as: 'help'
  get "/about", to: 'static_pages#about', as: 'about'
  get "/contact", to: 'static_pages#contact', as: 'contact'
  get "/signup", to: "users#new"
  resources :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # root "application#hello"
end
