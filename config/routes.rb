Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get :root, to: 'welcome#index'

  resources :merchants do
    resources :items, only: [:index]
  end

  resources :items, only: [:index, :show] do
    resources :reviews, only: [:new, :create]
  end

  resources :reviews, only: [:edit, :update, :destroy]

  get '/cart', to: 'cart#show'
  post '/cart/:item_id', to: 'cart#create'
  patch '/cart/:change/:item_id', to: 'cart#update'
  delete '/cart', to: 'cart#destroy'
  delete '/cart/:item_id', to: 'cart#destroy'

  get '/registration', to: 'users#new', as: :registration
  resources :users, only: [:create, :update]
  get '/profile', to: 'users#show'
  get '/profile/edit', to: 'users#edit'
  get '/profile/edit/password', to: 'users#edit'
  put '/user/assign_address/:address_id', to: 'users#update'

  get '/orders/new', to: 'user/orders#new'
  post '/orders', to: 'user/orders#create'
  get '/profile/orders', to: 'user/orders#index'
  get '/profile/orders/:id', to: 'user/orders#show'
  patch '/profile/orders/:order_id', to: 'user/orders#update'
  put '/profile/orders/:order_id', to: 'user/orders#update'

  resources :addresses, module: 'user', except: :show

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'

  namespace :merchant do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :orders, only: :show
    resources :items, only: [:index, :new, :create, :edit, :update, :destroy]
    put '/items/:id/change_status', to: 'items#update'
    get '/orders/:id/fulfill/:order_item_id', to: 'orders#update'
  end

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :merchants, only: [:show, :update]
    resources :users, only: [:index, :show]
    patch '/orders/:id/ship', to: 'orders#update'
  end
end
