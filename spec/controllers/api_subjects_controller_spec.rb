require 'rails_helper'
RSpec.describe APISubjectsController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: 'admin:api_subjects:*')
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :show' do
    let(:api_subject) { create(:api_subject) }

    before { get :show, id: api_subject.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/show') }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end
  end

  context 'patch :update' do
    let!(:api_subject) { create(:api_subject) }

    before do
      patch :update, id: api_subject.id,
                     api_subject: attributes_for(:api_subject)
    end

    it { is_expected.to redirect_to(api_subjects_path) }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with invalid attributes' do
      before do
        patch :update, id: api_subject.id,
                       api_subject: attributes_for(:api_subject,
                                                   x509_cn: 'not valid')
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('api_subjects/edit') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to save API Account\n\nX509 cn is invalid")
      end
    end
  end

  context 'post :destroy' do
    let!(:api_subject) { create(:api_subject) }

    def run
      delete :destroy, id: api_subject.id
    end

    subject { -> { run } }

    it { is_expected.to change(APISubject, :count).by(-1) }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(api_subjects_path) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(APISubject, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.not_to change(APISubject, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:redirect) }
      end
    end
  end

  context 'get :edit' do
    let!(:api_subject) { create(:api_subject) }
    before { get :edit, id: api_subject.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/edit') }
    it { is_expected.to have_assigned(:api_subject, api_subject) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    before { post :create, api_subject: attributes_for(:api_subject) }
    it { is_expected.to have_http_status(:redirect) }
    it { is_expected.to have_assigned(:api_subject, be_a(APISubject)) }

    it 'sets the flash message' do
      expect(flash[:success])
        .to eq("Created new API Account: #{APISubject.last.description}")
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with invalid attributes' do
      before do
        post :create, api_subject: attributes_for(:api_subject,
                                                  x509_cn: 'not valid')
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('new') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to create API Account\n\nX509 cn is invalid")
      end
    end
  end

  context 'get :new' do
    before { get :new }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/new') }
    it { is_expected.to have_assigned(:api_subject, be_a_new(APISubject)) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'get :index' do
    before { get :index }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subjects/index') }
    it { is_expected.to have_assigned(:api_subjects, APISubject.all) }

    context 'with no user' do
      let(:user) {}
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'as a non admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end
end
