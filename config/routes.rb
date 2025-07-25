Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"

    get "microposts/index"
    get "contact",   to:"static_pages#contact"
    get "home",   to: "static_pages#home"
    get "help",   to: "static_pages#help"

    get "/signup", to: "users#new", as: "signup"

    get    "login",   to: "sessions#new"
    post   "login",   to: "sessions#create"
    delete "logout",  to: "sessions#destroy"

    resources :users
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
  end
end
