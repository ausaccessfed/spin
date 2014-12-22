Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  get 'aws_idp', to: 'aws_idp#index' # Placeholder for now ...
  get 'no_projects_assigned', to: 'projects#no_projects_assigned'
  post 'login', to: 'sessions#create'
  root to: 'welcome#index'
end
