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

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'post create' do
      let(:organisation) { build(:organisation) }

      def to_map(organisation)
        organisation.attributes.symbolize_keys.slice(:name, :id, :external_id)
      end

      def run
        post_params = { organisation: to_map(organisation) }
        post :create, post_params.merge(format: 'json')
      end

      subject { -> { run } }

      it { is_expected.to change(Organisation, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'patch update' do
      let!(:organisation) { create(:organisation) }
      let(:updated_organisation) do
        build(:organisation,
              external_id: organisation.external_id,
              id: organisation.id)
      end

      def to_map(organisation)
        organisation.attributes.symbolize_keys
          .except(:created_at, :updated_at, :id)
      end

      def run
        patch_params = { organisation: to_map(updated_organisation) }
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
      end
    end

    context 'get :show' do
      before { get :show, format: 'json' }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/organisations/show') }

      it 'assigns the organisations' do
        expect(assigns[:organisations]).to eq(Organisation.all)
      end
    end

    context 'delete :id' do
      def run
        delete :destroy, id: object.id, format: 'json'
      end

      let!(:object) { create(:organisation) }

      subject { -> { run } }

      it { is_expected.to change(Organisation, :count).by(-1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
