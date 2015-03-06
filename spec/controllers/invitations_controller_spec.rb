require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do
  let(:invitation) { create(:invitation) }
  subject { response }

  context 'get :show' do
    def run
      get :show, identifier: invitation.identifier
    end

    context 'for an invalid identifier' do
      it 'raises an error' do
        # Causes a 404 in production
        expect { get :show, identifier: 'nonexistent' }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'for a used invite' do
      let(:invitation) { create(:invitation, used: true) }
      before { run }
      it { is_expected.to render_template('invitations/used') }
      it { is_expected.to have_assigned(:invitation, invitation) }
    end

    context 'for an expired invite' do
      let(:invitation) { create(:invitation, expires: 1.month.ago) }
      before { run }
      it { is_expected.to render_template('invitations/expired') }
      it { is_expected.to have_assigned(:invitation, invitation) }
    end

    context 'for a valid invite' do
      before { run }
      it { is_expected.to render_template('invitations/show') }
      it { is_expected.to have_assigned(:invitation, invitation) }
    end
  end

  context 'post :accept' do
    let(:user) { create(:subject) }

    def run
      post :accept, identifier: invitation.identifier
    end

    context 'for an invalid identifier' do
      it 'raises an error' do
        # Causes a 404 in production
        expect { post :accept, identifier: 'nonexistent' }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'assigns the invite code in the session' do
      expect { run }.to change { session[:invite] }.to(invitation.identifier)
    end

    it 'redirects' do
      run
      expect(response).to redirect_to('/auth/login')
    end
  end
end
