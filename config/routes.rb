Rails.application.routes.draw do

  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  root to: 'welcome#index'

end
