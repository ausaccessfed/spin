require 'rails_helper'

RSpec.describe ProjectsAdminController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: "organisations:#{organisation.id}:*")
  end
  let(:orig_attrs) { attributes_for(:project).except(:organisation) }
  let!(:organisation) { create(:organisation) }
  let(:project) do
    create(:project,
           orig_attrs.merge(organisation: organisation))
  end
  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :index' do
    let!(:project) { create(:project, organisation: organisation) }
    before { get :index, organisation_id: organisation.id }

    let(:user) do
      create(:subject, :authorized,
             permission: "organisations:#{organisation.id}:projects:*")
    end

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('projects_admin/index') }
    it { is_expected.to have_assigned(:organisation, organisation) }
    it { is_expected.to have_assigned(:projects, include(project)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) { nil }
      before { get :index, organisation_id: organisation.id }
      it { is_expected.to redirect_to('/auth/login') }
    end
  end

  context 'get :new' do
    before { get :new, organisation_id: organisation.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('projects_admin/new') }
    it { is_expected.to have_assigned(:organisation, organisation) }
    it { is_expected.to have_assigned(:project, be_a_new(Project)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :create' do
    def run
      post(:create, organisation_id: organisation.id, project: attrs)
    end

    let(:attrs) { attributes_for(:project) }
    subject { -> { run } }

    it { is_expected.to change(Project, :count).by(1) }
    it { is_expected.to have_assigned(:organisation, organisation) }
    it { is_expected.to have_assigned(:project, an_instance_of(Project)) }

    context 'the response' do
      before { run }
      subject { response }

      it 'sets the flash message' do
        expect(flash[:success])
          .to eq("Created Project #{project.name} for #{organisation.name}")
      end
      it do
        is_expected
          .to redirect_to(organisation_projects_path(organisation))
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Project, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end

    context 'with invalid attributes' do
      before do
        post :create, organisation_id: organisation.id,
                      project: attrs.merge(name: nil)
      end

      subject { response }

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('projects_admin/new') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to save Project\n\nName can't be blank")
      end
    end
  end

  context 'get :edit' do
    before { get :edit, organisation_id: organisation.id, id: project.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('projects_admin/edit') }
    it { is_expected.to have_assigned(:organisation, organisation) }
    it { is_expected.to have_assigned(:project, project) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'patch :update' do
    let(:attrs) { attributes_for(:project).slice(:name) }

    before do
      patch :update, organisation_id: organisation.id, id: project.id,
                     project: attrs
    end

    subject { response }

    it { is_expected.to redirect_to(organisation_projects_path(organisation)) }
    it { is_expected.to have_assigned(:organisation, organisation) }
    it { is_expected.to have_assigned(:project, project) }

    it 'sets the flash message' do
      expect(flash[:success])
        .to eq("Updated Project #{project.name} for #{organisation.name}")
    end

    context 'the project' do
      subject { project.reload }
      it { is_expected.to have_attributes(attrs) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }

      context 'the project' do
        subject { project.reload }
        it { is_expected.to have_attributes(orig_attrs) }
      end
    end

    context 'with invalid attributes' do
      before do
        patch :update, organisation_id: organisation.id, id: project.id,
                       project: attrs.merge(name: nil)
      end

      it { is_expected.to have_http_status(:success) }
      it { is_expected.to render_template('projects_admin/edit') }

      it 'sets the flash message' do
        expect(flash[:error])
          .to eq("Unable to save Project\n\nName can't be blank")
      end
    end
  end

  context 'delete :destroy' do
    def run
      delete :destroy, organisation_id: organisation.id, id: project.id
    end

    let!(:project) { create(:project, organisation: organisation) }
    subject { -> { run } }

    it { is_expected.to change(Project, :count).by(-1) }
    it { is_expected.to have_assigned(:organisation, organisation) }
    it { is_expected.to have_assigned(:project, project) }

    context 'the response' do
      before { run }
      subject { response }

      it 'sets the flash message' do
        expect(flash[:success])
          .to eq("Deleted Project #{project.name}")
      end

      it do
        is_expected
          .to redirect_to(organisation_projects_path(organisation))
      end
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Project, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end
end
