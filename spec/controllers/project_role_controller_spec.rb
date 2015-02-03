require 'rails_helper'

RSpec.describe ProjectRoleController, type: :controller do
  let!(:user) do
    create(:subject, :authorized,
           permission: "organisations:#{organisation.id}:" \
                       "projects:#{project.id}:*")
  end
  let!(:orig_attrs) { attributes_for(:project).except(:organisation) }
  let!(:organisation) { create(:organisation) }
  let!(:project) do
    create(:project,
           orig_attrs.merge(organisation: organisation))
  end
  let!(:project_role) { create(:project_role, project_id: project.id) }

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :show' do
    before do
      get :show, organisation_id: organisation.id, project_id: project.id,
                 id: project_role.id
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('project_role/show') }
    it { is_expected.to have_assigned(:project_role, project_role) }

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
    before do
      patch :update, organisation_id: organisation.id, project_id: project.id,
                     id: project_role.id,
                     project_role: attributes_for(:project_role)
    end

    it do
      is_expected.to redirect_to(organisation_project_roles_path(
                                        organisation, project))
    end

    it { is_expected.to have_assigned(:project_role, project_role) }

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
        patch :update, organisation_id: organisation.id, project_id: project.id,
                       id: project_role.id,
                       project_role: attributes_for(:project_role, name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('project_role/edit') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to save Project Role\n\nName can't be blank")
      end
    end
  end

  context 'post :destroy' do
    def run
      delete :destroy, organisation_id: organisation.id, project_id: project.id,
                       id: project_role.id,
                       project_role: attributes_for(:project_role)
    end

    subject { -> { run } }

    it { is_expected.to change(ProjectRole, :count).by(-1) }
    it { is_expected.to have_assigned(:project_role, project_role) }

    context 'the response' do
      before { run }
      subject { response }
      it do
        is_expected.to redirect_to(organisation_project_roles_path(
                                          organisation, project))
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(ProjectRole, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'with no user' do
      let(:user) {}
      it { is_expected.not_to change(ProjectRole, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:redirect) }
      end
    end
  end

  context 'get :edit' do
    before do
      get :edit, organisation_id: organisation.id,
                 project_id: project.id, id: project_role.id
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('project_role/edit') }
    it { is_expected.to have_assigned(:project_role, project_role) }

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
    before do
      post :create,  organisation_id: organisation.id,
                     project_id: project.id,
                     project_role: attributes_for(:project_role)
    end
    it { is_expected.to have_http_status(:redirect) }
    it { is_expected.to have_assigned(:project_role, be_a(ProjectRole)) }

    it 'sets the flash message' do
      expect(flash[:success])
        .to eq("Created Project Role #{ProjectRole.last.name}")
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
        post :create,  organisation_id: organisation.id,
                       project_id: project.id,
                       project_role: attributes_for(:project_role, name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('project_role/new') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to create Project Role\n\nName can't be blank")
      end
    end
  end

  context 'get :new' do
    before do
      get :new,  organisation_id: organisation.id,
                 project_id: project.id
    end
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('project_role/new') }
    it { is_expected.to have_assigned(:project_role, be_a_new(ProjectRole)) }

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
    before do
      get :index, organisation_id: organisation.id,
                  project_id: project.id
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('project_role/index') }
    it { is_expected.to have_assigned(:project_roles, ProjectRole.all) }

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
