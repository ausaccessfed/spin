Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  get 'aws_idp', to: 'aws_idp#index' # Placeholder for now ...
  get 'dashboard', to: 'dashboard#index'
  post 'login', to: 'sessions#create'

  scope '/admin' do
    resources :subjects, only: %i(index show destroy)
    resources :api_subjects
    resources :roles do
      resources :members, controller: 'subject_roles',
                          only: %i(new create destroy)
      resources :api_members, controller: 'api_subject_roles',
                              only: %i(new create destroy)
      resources :permissions, only: %i(index create destroy)
    end
    resources :organisations, except: 'show' do
      resources :projects, except: 'show', controller: 'projects_admin' do
        resources :roles, controller: 'project_role' do
          resources :members, controller: 'subject_project_roles',
                              only: %i(new create destroy)
        end
      end
    end
  end

  v1 = APIConstraints.new(version: 1, default: true)
  namespace :api, defaults: { format: 'json' } do
    scope 'subjects', constraints: v1 do
      get '/' => 'subjects#show'
      delete '/:id' => 'subjects#destroy'
    end
    scope 'organisations', constraints: v1 do
      post '/' => 'organisations#create'
      patch '/:id' => 'organisations#update'
      get '/' => 'organisations#show'
      delete '/:id' => 'organisations#destroy'
    end
  end

  root to: 'welcome#index'
end
