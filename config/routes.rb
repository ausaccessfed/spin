Rails.application.routes.draw do
  mount RapidRack::Engine => '/auth'
  get 'projects', to: 'projects#index'
  get 'dashboard', to: 'dashboard#index'
  post 'login', to: 'sessions#create'
  get 'aws_login', to: 'aws_session_instances#auto', as: :aws_login
  post 'aws_login', to: 'aws_session_instances#login'

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
    resources 'subjects', only: %i(index destroy create show), constraints: v1
    resources 'organisations', except: '%i(new show)', constraints: v1 do
      resources 'projects', except: '%i(new show)', constraints: v1 do
        resources 'roles', except: %i(new show), controller: 'project_roles',
                           constraints: v1 do
          resources 'members', controller: 'subject_project_roles',
                               only: %i(create destroy)
        end
      end
    end
  end

  root to: 'welcome#index'

  if Rails.env.development? || Rails.env.test?
    idp = lambda do |env|
      req = Rack::Request.new(env)
      instance = AWSSessionInstance
                 .find_by_identifier(req.cookies['spin_session_identifier'])

      if instance
        content = <<-EOF.gsub(/^ +/, '')
          A real deployment would sign in to AWS now.

          Subject: #{instance.subject.name}
          Project: #{instance.project_role.project.name}
          Role:    #{instance.project_role.name}
        EOF
      else
        content = 'No session instance found'
      end

      [200, { 'Content-Type' => 'text/plain' }, [content]]
    end

    mount idp => '/idp'
  end
end
