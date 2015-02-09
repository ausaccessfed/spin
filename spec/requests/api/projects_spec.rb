require 'rails_helper'

module API
  RSpec.describe ProjectsController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }
    let!(:organisation) { create(:organisation) }

    def to_map(project)
      project.attributes.symbolize_keys.slice(:name, :provider_arn, :active,
                                              :id)
    end

    context 'post /api/organisation/:id/projects' do
      let(:project) { build(:project) }

      def run
        post_params = { project: to_map(project) }
        post "/api/organisations/#{organisation.id}/projects", post_params,
             headers
      end

      it 'changes the project count' do
        expect { run }.to change(Project, :count).by(1)
      end
      it 'recieves http 201' do
        run
        expect(response).to have_http_status(:created)
      end
    end

    context 'patch /api/organisations/:id/projects/:id' do
      let!(:project) { create(:project, organisation: organisation) }
      let(:updated_project) { build(:project, id: project.id) }

      def run
        patch_params = { project: to_map(updated_project) }
        patch "/api/organisations/#{organisation.id}/projects/#{project.id}",
              patch_params, headers
      end

      it 'does not change project count' do
        expect { run }.not_to change(Project, :count)
      end

      context 'request outcomes' do
        before { run }
        it 'updates project instance with new attributes' do
          expect(to_map(project.reload)).to eq(to_map(updated_project))
        end
        it 'recieves http 200' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'get /api/organisations/:id/projects' do
      let!(:project1) { create(:project, organisation: organisation) }
      let!(:project2) { create(:project, organisation: organisation) }
      let(:json) { JSON.parse(response.body, symbolize_names: true) }

      before do
        get "/api/organisations/#{organisation.id}/projects", nil, headers
      end

      it 'recieves http 200' do
        expect(response).to have_http_status(:ok)
      end

      context 'recieved json projects' do
        subject { json[:projects] }
        it { is_expected.to include(to_map(project1)) }
        it { is_expected.to include(to_map(project2)) }
      end
    end

    context 'delete /api/organisations/:id/projects/:id' do
      let!(:project) { create(:project, organisation: organisation) }

      def run
        delete "/api/organisations/#{organisation.id}/projects/#{project.id}",
               nil, headers
      end

      it 'deletes the project' do
        expect { run }.to change(Project, :count).by(-1)
      end
      it 'recieves http 200' do
        run
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
