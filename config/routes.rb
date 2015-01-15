Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  get 'aws_idp', to: 'aws_idp#index' # Placeholder for now ...
  get 'no_projects_assigned', to: 'projects#no_projects_assigned'
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

  root to: 'welcome#index'
end
