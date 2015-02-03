require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET index' do
    it 'redirects to login' do
      get :index
      expect(response).to redirect_to('/auth/login')
    end

    context 'with authorized user' do
      let(:user) do
        create(:subject, :authorized)
      end

      before { session[:subject_id] = user.try(:id) }
      subject { response }

      it { is_expected.to have_http_status(:success) }
    end
  end
end
