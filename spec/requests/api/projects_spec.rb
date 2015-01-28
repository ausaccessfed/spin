require 'rails_helper'

module API
  RSpec.describe ProjectsController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }
    let!(:organisation) { create(:organisation) }
    let(:orig_attrs) { attributes_for(:project).except(:organisation) }
    subject { response }

    def to_map(project)
      project.attributes.symbolize_keys.slice(:name, :provider_arn, :state,
                                              :id)
    end

    context 'post /api/organisation/:id/projects' do
      let(:project) { build(:project) }

      def run
        post_params = { project: to_map(project) }
        post "/api/organisations/#{organisation.id}/projects", post_params,
             headers
      end

      subject { -> { run } }

      it { is_expected.to change(Project, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'patch /api/organisations/:id/projects/:id' do
      let!(:project) do
        create(:project,
               orig_attrs.merge(organisation: organisation))
      end
      let(:updated_project) do
        build(:project, id: project.id)
      end

      def run
        patch_params = { project: to_map(updated_project) }
        patch "/api/organisations/#{organisation.id}/projects/#{project.id}",
              patch_params, headers
      end

      subject { -> { run } }

      it { is_expected.to change(Project, :count).by(0) }

      context 'the updated project' do
        it 'has the attributes' do
          expect(to_map(project.reload))
            .to eq(to_map(updated_project))
        end
      end

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'get /api/organisations/:id/projects' do
      let!(:project1) do
        create(:project,
               orig_attrs.merge(organisation: organisation))
      end
      let!(:project2) do
        create(:project,
               orig_attrs.merge(organisation: organisation))
      end
      def run
        get "/api/organisations/#{organisation.id}/projects", nil, headers
      end

      let(:json) { JSON.parse(response.body, symbolize_names: true) }

      before { run }

      it { is_expected.to have_http_status(:ok) }

      context 'the response' do
        subject { json[:projects] }
        it { is_expected.to include(to_map(project1)) }
        it { is_expected.to include(to_map(project2)) }
      end
    end

    context 'delete /api/organisations/:id/projects/:id' do
      let!(:project) do
        create(:project,
               orig_attrs.merge(organisation: organisation))
      end

      def run
        delete "/api/organisations/#{organisation.id}/projects/#{project.id}",
               nil, headers
      end

      subject { -> { run } }

      it { is_expected.to change(Project, :count).by(-1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
