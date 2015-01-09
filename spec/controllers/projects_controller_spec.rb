require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe 'GET index' do
    it 'redirects to login' do
      get :index
      expect(response).to redirect_to('/auth/login')
    end

    context 'as a permitted user' do
      context 'with no projects assigned' do
        let(:subject) { create(:subject) }
        before do
          session[:subject_id] = subject.id
          get :index
        end
        it 'has no projects' do
          expect(assigns(:projects)).to eq([])
        end
        it 'has 200 response' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'with many projects assigned' do
        let(:authorized_subject) do
          create(:subject,
                 :assigned_to_many_projects)
        end

        before do
          session[:subject_id] = authorized_subject.id
          get :index
        end

        it 'has 200 response' do
          expect(response).to have_http_status(:success)
        end

        it 'has a unique set of projects' do
          expect(assigns(:projects)).to contain_exactly(an_instance_of(Project),
                                                        an_instance_of(Project))
        end
      end
    end
  end
end
