require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST create' do
    context 'with no consent' do
      it 'redirects to root' do
        post :create
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with consent' do
      it 'redirects to login' do
        post :create, agree_to_consent: 'on'
        expect(response).to redirect_to('/auth/login')
      end
    end
  end
end
