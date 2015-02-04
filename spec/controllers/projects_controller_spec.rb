require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe 'GET index' do
    it 'redirects to login' do
      get :index
      expect(response).to redirect_to('/auth/login')
    end

    context 'as a permitted user' do
      let(:subject) { create(:subject) }

      context 'with no projects assigned' do
        before do
          session[:subject_id] = subject.id
          get :index
        end
        it 'has no projects' do
          expect(assigns(:projects)).to be_empty
        end
        it 'has 200 response' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'with multiple inactive and active projects' do
        include_context 'projects'

        before do
          2.times { create_active_project(subject) }
          5.times { create_inactive_project(subject) }
        end

        before do
          session[:subject_id] = subject.id
          get :index
        end

        it 'has 200 response' do
          expect(response).to have_http_status(:success)
        end

        it 'has the expected number of Project objects' do
          expect(assigns(:projects).keys)
            .to contain_exactly(an_instance_of(Project),
                                an_instance_of(Project))
        end

        it 'have the status of active' do
          expect(assigns(:projects).keys.find(&:active)).to_not be_nil
        end
      end
    end
  end
end
