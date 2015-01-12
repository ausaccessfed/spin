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
    it { is_expected.to have_assigned(:objects, include(object)) }

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
end
