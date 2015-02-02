require 'rails_helper'

module API
  RSpec.describe ProjectRolesController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }
    let!(:organisation) { create(:organisation) }
    let!(:project) { create(:project, organisation_id: organisation.id) }
    let(:orig_attrs) { attributes_for(:project_role).except(:project) }
    subject { response }

    def to_map(project_role)
      project_role.attributes.symbolize_keys.slice(:name, :role_arn, :id)
        .merge(granted_subjects: project_role.subjects.map(&:id))
    end

    def base_url
      "/api/organisations/#{organisation.id}/projects/#{project.id}/roles"
    end

    context 'post /api/organisation/:id/projects/:id/roles' do
      let(:project_role) { build(:project_role) }

      def run
        post_params = { project_role: to_map(project_role) }
        post base_url, post_params, headers
      end

      subject { -> { run } }

      it { is_expected.to change(ProjectRole, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'patch /api/organisations/:id/projects/:id/roles/:id' do
      let!(:project_role) do
        create(:project_role,
               orig_attrs.merge(project: project))
      end
      let(:updated_project_role) do
        build(:project_role, id: project_role.id)
      end

      def run
        patch_params = { project_role: to_map(updated_project_role) }
        patch "#{base_url}/#{project_role.id}",  patch_params, headers
      end

      subject { -> { run } }

      it { is_expected.to change(ProjectRole, :count).by(0) }

      context 'the updated project_role' do
        it 'has the attributes' do
          expect(to_map(project_role.reload))
            .to eq(to_map(updated_project_role))
        end
      end

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'get /api/organisations/:id/projects/:id/roles' do
      let!(:project_role1) do
        create(:project_role,
               orig_attrs.merge(project: project))
      end
      let!(:project_role2) do
        create(:project_role,
               orig_attrs.merge(project: project))
      end

      let!(:subject_project_role1) do
        create(:subject_project_role,
               subject: create(:subject),
               project_role: project_role1)
      end

      let!(:subject_project_role2) do
        create(:subject_project_role,
               subject: create(:subject),
               project_role: project_role1)
      end
      def run
        get base_url, nil, headers
      end

      let(:json) { JSON.parse(response.body, symbolize_names: true) }

      before { run }

      it { is_expected.to have_http_status(:ok) }

      context 'the response' do
        subject { json[:project_roles] }
        it { is_expected.to include(to_map(project_role1)) }
        it { is_expected.to include(to_map(project_role2)) }
      end
    end

    context 'delete /api/organisations/:id/projects/:id/roles/:id' do
      let!(:project_role) do
        create(:project_role,
               orig_attrs.merge(project: project))
      end

      def run
        delete "#{base_url}/#{project_role.id}", nil, headers
      end

      subject { -> { run } }

      it { is_expected.to change(ProjectRole, :count).by(-1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
