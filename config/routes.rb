Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  get 'no_projects_assigned', to: 'projects#no_projects_assigned'
  post 'login', to: 'sessions#create'
  root to: 'welcome#index'
end
