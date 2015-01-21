require 'rails_helper'

RSpec.describe APISubjectRolesController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: 'admin:roles:*')
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  let(:api_subject) { create(:api_subject) }
  let(:role) { create(:role) }
  let(:base_params) { { role_id: role.id } }
  let(:model_class) { APISubjectRole }

  context 'get :new' do
    before { get :new, base_params }

    it { is_expected.to have_assigned(:role, role) }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('api_subject_roles/new') }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'as a non-authenticated user' do
      let(:user) { nil }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'post :create' do
    def run
      post(:create, base_params.merge(api_subject_roles: attrs))
    end

    let(:attrs) { { api_subject_id: api_subject.id } }

    subject { -> { run } }

    it { is_expected.to have_assigned(:role, role) }
    it { is_expected.to have_assigned(:assoc, an_instance_of(model_class)) }
    it { is_expected.to change(model_class, :count).by(1) }

    context 'the response' do
      before { run }
      subject { response }

      it { is_expected.to redirect_to(role_path(role)) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(model_class, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'when association has already been created' do
      before do
        create(:api_subject_role, role: role,
                                  api_subject: api_subject)
      end

      it { is_expected.to change(model_class, :count).by(0) }

      context 'the response' do
        before { run }
        subject { response }

        it 'sets the flash message' do
          expect(flash[:error])
            .to eq('API subject already has this role granted')
        end
      end
    end
  end

  context 'delete :destroy' do
    def run
      delete :destroy, base_params.merge(id: assoc.id)
    end

    let!(:assoc) { create(:api_subject_role, role: role) }
    subject { -> { run } }
    it { is_expected.to have_assigned(:role, role) }
    it { is_expected.to have_assigned(:assoc, assoc) }
    it { is_expected.to change(model_class, :count).by(-1) }

    context 'the response' do
      before { run }
      subject { response }

      it { is_expected.to redirect_to(role_path(role)) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(model_class, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end
end
