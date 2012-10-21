require 'resque/server'

R12Team33::Application.routes.draw do
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'
  match 'current_user', to: 'sessions#current_twitter_user'
  match 'uuid', to: 'sessions#uuid'

  resources :links, only: [:index]

  mount Resque::Server.new, :at => "/resque"

  root :to => 'welcome#index'
end
