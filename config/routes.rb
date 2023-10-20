Rails.application.routes.draw do
  namespace :admin do
    get 'kyc/index'
    get 'kyc/approve'
    get 'kyc/reject'
  end
  
    devise_for :users, defaults: { format: :json }, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
    
  }

  devise_for :admins, defaults: { format: :json }, controllers: {
    registrations: 'admin/registrations',
    sessions: 'admin/sessions',
    confirmations: 'admin/confirmations'    
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # get "/login", to: redirect("/auth/google_oauth2")
  # get "/logout". to: "sessions#destroy"
  # get "/auth/google_oauth2/callback", to: "sessions#create"
  # get "auth/failure", to: redirect('/')
  

  # Defines the root path route ("/")
  # root "articles#index"
  devise_scope :user do
    post '/users/sessions/create', to: 'users/sessions#create'
    post '/users/registrations/create', to: 'users/registrations#create'
    post '/users/set_initial_password', to: 'users/passwords#new', as: :set_initial_password
    post '/users/update_initial_password', to: 'users/passwords#update'
    post '/kyc', to: 'kyc#create'
    post '/kyc-update', to: 'kyc#update'
  end

 # devise_scope :admin do
 #   post '/admins/sessions/create', to: 'admin/sessions#create'
    
 # end

  namespace :admin do
    resources :kyc, only: [:index] do
      member do
        post :approve
        post :reject
      end
    end

    
    resources :users, only: [:index, :show, :create, :update, :destroy]
    resources :crops
    resources :transactions, only: [:index, :show, :update, :destroy]
 
  end

  resources :users do
    resources :crops, module: :users
    resources :transactions, only: [:index, :show, :create, :update], module: :users do
      resources :transaction_crops, only: [:index, :create, :update, :destroy]
    end
  end

  get '/market', to: 'users/crops#show_all'
  
  get '/users/:user_id/transaction-crops', to: 'users/transaction_crops#index'

  
end

