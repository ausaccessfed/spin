require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: 'admin:roles:*')
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :show' do
    let(:role) { create(:role) }

    before { get :show, id: role.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/show') }
    it { is_expected.to have_assigned(:role, role) }

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
    let!(:role) { create(:role) }

    before do
      patch :update, id: role.id,
                     role: attributes_for(:role)
    end

    it { is_expected.to redirect_to(roles_path) }
    it { is_expected.to have_assigned(:role, role) }

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
        patch :update, id: role.id,
                       role: attributes_for(:role, name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('roles/edit') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to save Role\n\nName can't be blank")
      end
    end
  end

  context 'post :destroy' do
    let!(:role) { create(:role) }

    def run
      delete :destroy, id: role.id
    end

    subject { -> { run } }

    it { is_expected.to change(Role, :count).by(-1) }
    it { is_expected.to have_assigned(:role, role) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(roles_path) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Role, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.not_to change(Role, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:redirect) }
      end
    end
  end

  context 'get :edit' do
    let!(:role) { create(:role) }
    before { get :edit, id: role.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/edit') }
    it { is_expected.to have_assigned(:role, role) }

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
    before { post :create, role: attributes_for(:role) }
    it { is_expected.to have_http_status(:redirect) }
    it { is_expected.to have_assigned(:role, be_a(Role)) }

    it 'sets the flash message' do
      expect(flash[:success])
        .to eq("Created new Role: #{Role.last.name}")
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
        post :create, role: attributes_for(:role,
                                           name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('new') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to create Role\n\nName can't be blank")
      end
    end
  end

  context 'get :new' do
    before { get :new }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('roles/new') }
    it { is_expected.to have_assigned(:role, be_a_new(Role)) }

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
    it { is_expected.to render_template('roles/index') }
    it { is_expected.to have_assigned(:roles, Role.all) }

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
