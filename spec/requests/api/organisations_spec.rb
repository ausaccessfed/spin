require 'rails_helper'

module API
  RSpec.describe OrganisationsController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }

    subject { response }

    def to_map(organisation)
      organisation.attributes.symbolize_keys
        .slice(:name, :id, :external_id)
    end

    context 'post /api/organisations' do
      let(:organisation) { build(:organisation) }

      def run
        post_params = { organisation: to_map(organisation) }
        post '/api/organisations', post_params, headers
      end

      subject { -> { run } }

      it { is_expected.to change(Organisation, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:created) }
      end
    end

    context 'patch /api/organisations/:id' do
      let!(:organisation) { create(:organisation) }
      let(:updated_organisation) do
        build(:organisation,
              external_id: organisation.external_id,
              id: organisation.id)
      end

      def run
        patch_params = { organisation: to_map(updated_organisation) }
        patch "/api/organisations/#{organisation.id}", patch_params, headers
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

    context 'get /api/organisations' do
      let!(:organisation1) { create(:organisation) }
      let!(:organisation2) { create(:organisation) }
      def run
        get '/api/organisations', nil, headers
      end

      def to_map(organisation)
        organisation.attributes.symbolize_keys.slice(:name, :external_id, :id)
      end

      let(:json) { JSON.parse(response.body, symbolize_names: true) }

      before { run }

      it { is_expected.to have_http_status(:ok) }

      context 'the response' do
        subject { json[:organisations] }
        it { is_expected.to include(to_map(organisation1)) }
        it { is_expected.to include(to_map(organisation2)) }
      end
    end

    context 'delete /api/organisations/:id' do
      let!(:organisation) { create(:organisation) }
      def run
        delete "/api/organisations/#{organisation.id}", nil, headers
      end

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
