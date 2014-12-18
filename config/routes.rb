Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  post 'login', to: 'sessions#create'
  root to: 'welcome#index'
end
