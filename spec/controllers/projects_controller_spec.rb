require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do

  describe 'GET index' do

    it 'redirects to login' do
      get :index
      expect(response).to redirect_to('/auth/login')
    end

    context 'as a permitted user' do
      let(:user) { create(:subject) }
      before { session[:subject_id] = user.id }

      it 'shows the projects' do
        get :index
        expect(response).to have_http_status(:success)
      end

    end

  end

end
