require 'rails_helper'

module API
  RSpec.describe OrganisationsController, type: :controller do
    let(:api_subject) do
      role = create(:role)
      user = create(:api_subject, :authorized,
                    permission: 'api:organisations:*')
      create(:api_subject_role, role: role, api_subject: user)
      user
    end

    def to_map(organisation)
      organisation.attributes.symbolize_keys.slice(:name, :id, :external_id)
    end

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'post :create' do
      def run
        post_params = { organisation: to_map(organisation) }
        post :create, post_params.merge(format: 'json')
      end

      context 'with valid params' do
        let(:organisation) { build(:organisation) }

        subject { -> { run } }

        it { is_expected.to change(Organisation, :count).by(1) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:ok) }
          context 'body' do
            subject { response.body }
            it do
              is_expected.to eq("Organisation #{Organisation.last.id} created")
            end
          end
        end
      end

      context 'with invalid params' do
        let(:organisation) { build(:organisation, name: nil) }

        subject { -> { run } }

        it { is_expected.to change(Organisation, :count).by(0) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:bad_request) }
          context 'body' do
            subject { response.body }
            it do
              is_expected.to eq("{\"error\":\"Validation failed:" \
                                " Name can't be blank\"}")
            end
          end
        end
      end
    end

    context 'patch :update' do
      let!(:organisation) { create(:organisation) }
      let(:updated_organisation) do
        build(:organisation,
              external_id: organisation.external_id,
              id: organisation.id)
      end

      let(:patch_params) { { organisation: to_map(updated_organisation) } }

      def run
        patch :update, id: organisation.id,
                       organisation: patch_params.merge(format: 'json')
      end

      subject { -> { run } }

      it { is_expected.to change(Organisation, :count).by(0) }

      context 'the updated organisation' do
        it 'has the attributes' do
          expect(to_map(organisation.reload))
            .to eq(to_map(updated_organisation))
        end
      end

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
        context 'body' do
          subject { response.body }
          it do
            is_expected.to eq("Organisation #{organisation.id} updated")
          end
        end
      end
    end

    context 'get :index' do
      before { get :index, format: 'json' }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/organisations/index') }

      it 'assigns the organisations' do
        expect(assigns[:organisations]).to eq(Organisation.all)
      end
    end

    context 'delete :id' do
      context 'when the organisation does not exist' do
        def run
          delete :destroy, id: -1, format: 'json'
        end

        subject { -> { run } }

        it { is_expected.to change(Organisation, :count).by(0) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end

      context 'when the organisation exists' do
        def run
          delete :destroy, id: organisation.id, format: 'json'
        end

        let!(:organisation) { create(:organisation) }

        subject { -> { run } }

        it { is_expected.to change(Organisation, :count).by(-1) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:ok) }
          context 'body' do
            subject { response.body }
            it do
              is_expected.to eq("Organisation #{organisation.id} deleted")
            end
          end
        end
      end
    end
  end
end
