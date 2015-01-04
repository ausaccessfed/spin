require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe 'GET index' do
    it 'redirects to login' do
      get :index
      expect(response).to redirect_to(root_path)
    end

    context 'as a permitted user' do
      context 'with no projects assigned' do
        let(:subject) { create(:subject) }
        before { session[:subject_id] = subject.id }
        it 'has no projects' do
          get :index
          expect(response).to have_http_status(:success)
          expect(assigns(:projects)).to eq([])
        end
      end

      context 'with many projects assigned' do
        let(:authorized_subject) do
          create(:subject,
                 :authorized_for_many_projects)
        end
        before { session[:subject_id] = authorized_subject.id }
        it 'has a unique set of projects' do
          get :index
          expect(response).to have_http_status(:success)
          expect(assigns(:projects)).to be_a Array
          expect(assigns(:projects).size).to be 2
          assigns(:projects).each do | p |
            expect(p).to be_a Project
          end
        end
      end
    end
  end
end
