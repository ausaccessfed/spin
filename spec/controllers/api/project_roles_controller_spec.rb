require 'rails_helper'

module API
  RSpec.describe ProjectRolesController, type: :controller do
    let!(:organisation) { create(:organisation) }
    let!(:project) { create(:project, organisation_id: organisation.id) }
    let(:api_subject) do
      role = create(:role)
      user = create(:api_subject, :authorized,
                    permission: 'api:organisations' \
                                ":#{organisation.id}:projects:#{project.id}:*")
      create(:api_subject_role, role: role, api_subject: user)
      user
    end

    let(:orig_attrs) { attributes_for(:project_role).except(:project) }

    def to_map(project_role)
      project_role.attributes.symbolize_keys.slice(:name, :role_arn)
    end

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'post :create' do
      let(:project_role) { build(:project_role) }

      def run
        post :create, organisation_id: organisation.id, project_id: project.id,
                      project_role: to_map(project_role)
      end

      subject { -> { run } }

      it { is_expected.to change(ProjectRole, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end

      context 'with invalid params' do
        let(:project_role) { build(:project_role, name: nil) }

        it { is_expected.to change(ProjectRole, :count).by(0) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:bad_request) }
          context 'body' do
            subject { response.body }
            it do
              is_expected.to eq("{\"error\":\"Validation failed: Name can't" \
                                " be blank\"}")
            end
          end
        end
      end
    end

    context 'patch :update' do
      let!(:project_role) do
        create(:project_role,
               orig_attrs.merge(project: project))
      end
      let(:updated_project_role) do
        build(:project_role, id: project_role.id)
      end

      def run
        patch :update, organisation_id: organisation.id, project_id: project.id,
                       id: updated_project_role.id,
                       project_role: to_map(updated_project_role)
                         .merge(format: 'json')
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

      context 'with invalid params' do
        let(:updated_project_role) do
          build(:project_role, id: project_role.id,
                               role_arn: 'arn:aws:iam::1:$')
        end

        it { is_expected.to change(ProjectRole, :count).by(0) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:bad_request) }
          context 'body' do
            subject { response.body }
            it do
              is_expected.to eq("{\"error\":\"Validation failed: Role ARN" \
              " format must be 'arn:aws:iam::(number):role/(string)'\"}")
            end
          end
        end
      end
    end

    context 'get :index' do
      before do
        get :index, organisation_id: organisation.id,
                    project_id: project.id, format: 'json'
      end

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/project_roles/index') }

      it 'assigns the project_roles' do
        expect(assigns[:project_roles]).to eq(project.project_roles)
      end
    end

    context 'delete :id' do
      def run
        delete :destroy, organisation_id: organisation.id,
                         project_id: project.id, id: project_role.id,
                         format: 'json'
      end

      subject { -> { run } }

      context 'when the project role exists' do
        let!(:project_role) do
          create(:project_role,
                 orig_attrs.merge(project: project))
        end

        it { is_expected.to change(ProjectRole, :count).by(-1) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end

      context 'when the project role does not exist' do
        def run
          delete :destroy, organisation_id: organisation.id,
                           project_id: project.id, id: -1, format: 'json'
        end

        subject { -> { run } }

        it { is_expected.to change(ProjectRole, :count).by(0) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
          context 'body' do
            subject { response.body }
            it do
              is_expected.to eq("{\"error\":\"Resource not found\"}")
            end
          end
        end
      end
    end
  end
end
