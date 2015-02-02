require 'rails_helper'

module API
  RSpec.describe SubjectProjectRolesController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }
    let!(:organisation) { create(:organisation) }
    let!(:project) { create(:project, organisation_id: organisation.id) }
    let!(:project_role) { create(:project_role, project: project) }
    let!(:user) { create(:subject) }

    subject { response }

    def base_url
      "/api/organisations/#{organisation.id}/projects/#{project.id}/" \
      "roles/#{project_role.id}/members"
    end

    context 'post /api/organisation/:id/projects/:id/roles/:id/members' do
      def run
        post_params = { subject_project_roles:
                            { subject_id: user.id } }
        post base_url, post_params, headers
      end

      subject { -> { run } }

      it { is_expected.to change(SubjectProjectRole, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'delete /api/organisations/:id/projects/:id/roles/:id/members' do
      let!(:subject_project_role) do
        create(:subject_project_role, project_role: project_role, subject: user)
      end

      def run
        delete "#{base_url}/#{user.id}", nil, headers
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
