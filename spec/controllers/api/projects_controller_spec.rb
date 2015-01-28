require 'rails_helper'

module API
  RSpec.describe ProjectsController, type: :controller do
    let!(:organisation) { create(:organisation) }
    let(:api_subject) do
      role = create(:role)
      user = create(:api_subject, :authorized,
                    permission: 'api:organisations' \
                                ":#{organisation.id}:projects:*")
      create(:api_subject_role, role: role, api_subject: user)
      user
    end

    let(:orig_attrs) { attributes_for(:project).except(:organisation) }

    def to_map(project)
      project.attributes.symbolize_keys.slice(:name, :provider_arn, :state)
    end

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'post create' do
      let(:project) { build(:project) }

      def run
        post :create, organisation_id: organisation.id, project: to_map(project)
      end

      subject { -> { run } }

      it { is_expected.to change(Project, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'patch update' do
      let!(:project) do
        create(:project,
               orig_attrs.merge(organisation: organisation))
      end
      let(:updated_project) do
        build(:project, id: project.id)
      end

      def run
        patch :update, organisation_id: organisation.id, id: updated_project.id,
                       project: to_map(updated_project).merge(format: 'json')
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

    context 'get :index' do
      before { get :index, organisation_id: organisation.id, format: 'json' }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/projects/index') }

      it 'assigns the projects' do
        expect(assigns[:projects]).to eq(Project.all)
      end
    end

    context 'delete :id' do
      let!(:project) do
        create(:project,
               orig_attrs.merge(organisation: organisation))
      end

      def run
        delete :destroy, organisation_id: organisation.id, id: project.id,
                         format: 'json'
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
