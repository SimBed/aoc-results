Rails.application.routes.draw do
  resources :rel_pair_comps
  resources :pairs
  resources :players
  resources :comps
  root 'comps#index'
end
