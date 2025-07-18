Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"

    get "microposts/index"
    get "static_pages/contact"
    get "static_pages/home"
    get "static_pages/help"

    get "/signup", to: "users#new", as: "signup"
    post "/signup", to: "users#create"

    resources :users, only: :show
  end
end
