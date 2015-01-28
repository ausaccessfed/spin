require 'rails_helper'

module API
  RSpec.describe SubjectProjectRolesController, type: :controller do
    let!(:organisation) { create(:organisation) }
    let!(:project) { create(:project, organisation_id: organisation.id) }
    let!(:project_role) { create(:project_role, project_id: project.id) }
    let!(:user) { create(:subject) }

    let(:api_subject) do
      role = create(:role)
      user = create(:api_subject, :authorized,
                    permission: 'api:organisations' \
                                ":#{organisation.id}:projects:#{project.id}:*")
      create(:api_subject_role, role: role, api_subject: user)
      user
    end

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'post :create' do
      def run
        post :create, organisation_id: organisation.id, project_id: project.id,
                      role_id: project_role.id, subject_project_roles:
                      { subject_id: user.id }
      end

      subject { -> { run } }

      it { is_expected.to change(SubjectProjectRole, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'delete :id' do
      let!(:subject_project_role) do
        create(:subject_project_role,
               project_role: project_role)
      end

      def run
        delete :destroy, organisation_id: organisation.id,
                         project_id: project.id, role_id: project_role.id,
                         id: subject_project_role.id, format: 'json'
      end

      subject { -> { run } }

      it { is_expected.to change(SubjectProjectRole, :count).by(-1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
