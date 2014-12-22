require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe 'GET index' do
    it 'redirects to login if not permitted' do
      get :index
      expect(response).to redirect_to(root_path)
    end

    context 'as a permitted user' do
      let(:user) { create(:subject) }
      before { session[:subject_id] = user.id }

      include_context 'a mocked subject'

      context 'with no projects' do
        include_context 'with no projects'

        it 'shows no projects' do
          get :index
          expect(response).to have_http_status(:success)
          assigns(:projects) == []
        end
      end

      context 'with multiple projects' do
        include_context 'with 3 projects'

        it 'shows all projects' do
          get :index
          expect(response).to have_http_status(:success)
          assigns(:projects) == []
        end
      end
    end
  end
end
