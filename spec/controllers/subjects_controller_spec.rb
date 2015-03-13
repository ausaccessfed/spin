require 'rails_helper'

RSpec.describe SubjectsController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'admin:subjects:*') }
  before { session[:subject_id] = user.try(:id) }
  subject { response }

  let(:object) { create(:subject) }

  context 'get :index' do
    let!(:object) { create(:subject) }

    before { get :index }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('subjects/index') }
    it { is_expected.to have_assigned(:subjects, include(object)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) { nil }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'get :show' do
    before { get :show, id: object.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('subjects/show') }
    it { is_expected.to have_assigned(:object, object) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :destroy' do
    def run
      delete :destroy, id: object.id
    end

    let!(:object) { create(:subject) }
    subject { -> { run } }

    it { is_expected.to change(Subject, :count).by(-1) }
    it { is_expected.to have_assigned(:object, object) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(subjects_path) }
      it 'sets the flash message' do
        expect(flash[:success])
          .to eq("Deleted user #{object.name}")
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Subject, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'patch :resend_invite' do
    def run
      patch :resend_invite, id: object.id
    end

    let(:mail) { Faker::Internet.email }
    let!(:object) { create(:subject, mail: mail) }
    let!(:invitation) do
      create(:invitation, subject: object, mail: mail,
                          last_email_sent_at: Time.new(2010, 6, 21))
    end
    subject { -> { run } }

    context 'the invitiation' do
      before { run }
      it 'is sent' do
        expect(response).to have_sent_email.to(mail)
      end
    end

    context 'the invitation' do
      let!(:original_last_email_sent_at) { invitation.last_email_sent_at }
      before { run }
      it 'updates last_email_sent_at' do
        expect(invitation.reload.last_email_sent_at)
          .to be > original_last_email_sent_at
      end
    end

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(subject_path(object.id)) }
      it 'sets the flash message' do
        expect(flash[:success]).to eq("Sent email to #{mail}")
      end
    end
  end
end
