V2MoviePong::Application.routes.draw do
  get '/login' => 'session#new'
  post 'login' => 'session#create'
  delete '/login' => 'session#destroy'
  root :to => 'games#index'
  resources :users, :only => [:new, :create, :show]
  resources :games, :only => [:create] do
    member do
      post "play"
      get "start"
      get "get_info"
    end
  end

end
