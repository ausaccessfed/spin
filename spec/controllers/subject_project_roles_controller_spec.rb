require 'rails_helper'

RSpec.describe SubjectProjectRolesController, type: :controller do
  def permission_string
    "organisations:#{organisation.id}:projects:#{project.id}:*"
  end

  let(:user) { create(:subject, :authorized, permission: permission_string) }
  let(:organisation) { create(:organisation) }
  let(:project) { create(:project, organisation: organisation) }
  let(:project_role) { create(:project_role, project_id: project.id) }
  let(:object) { create(:subject) }
  let(:base_params) do
    { role_id: project_role.id,
      project_id: project.id,
      organisation_id: organisation.id }
  end
  let(:model_class) { SubjectProjectRole }

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  context 'get :new' do
    before { get :new, base_params }

    it { is_expected.to have_assigned(:project_role, project_role) }
    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('subject_project_roles/new') }

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
      post(:create, base_params.merge(subject_project_roles: attrs))
    end

    let(:attrs) { { subject_id: object.id } }

    subject { -> { run } }

    it { is_expected.to have_assigned(:project_role, project_role) }
    it { is_expected.to have_assigned(:assoc, an_instance_of(model_class)) }
    it { is_expected.to change(model_class, :count).by(1) }

    context 'when association has already been created' do
      before do
        create(:subject_project_role, project_role: project_role,
                                      subject: object)
      end

      it { is_expected.to change(model_class, :count).by(0) }

      context 'the response' do
        before { run }
        subject { response }
        it 'sets the flash message' do
          expect(flash[:error])
            .to eq('Subject already has this role granted')
        end
      end
    end

    context 'the response' do
      before { run }
      subject { response }

      it do
        is_expected
          .to redirect_to(organisation_project_role_path(organisation,
                                                         project, project_role))
      end
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

  context 'delete :destroy' do
    def run
      delete :destroy, base_params.merge(id: assoc.id)
    end

    let!(:assoc) { create(:subject_project_role, project_role: project_role) }
    subject { -> { run } }
    it { is_expected.to have_assigned(:project_role, project_role) }
    it { is_expected.to have_assigned(:assoc, assoc) }
    it { is_expected.to change(model_class, :count).by(-1) }

    context 'the response' do
      before { run }
      subject { response }

      it do
        is_expected
          .to redirect_to(organisation_project_role_path(organisation,
                                                         project, project_role))
      end
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
