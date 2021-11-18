Rails.application.routes.draw do
  get '/players/filter', to: 'players#filter'
  resources :rel_pair_comps
  resources :pairs
  resources :players
  resources :comps
  root 'comps#index'


end
