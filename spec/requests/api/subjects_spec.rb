require 'rails_helper'

module API
  RSpec.describe SubjectsController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }
    let!(:user1) { create(:subject) }
    let!(:user2) { create(:subject) }

    subject { response }

    context 'get /api/subjects' do
      def run
        get '/api/subjects', nil, headers
      end

      def to_map(subject)
        subject.attributes.symbolize_keys.slice(:name, :mail, :shared_token,
                                                :id)
      end

      let(:json) { JSON.parse(response.body, symbolize_names: true) }

      before { run }

      it { is_expected.to have_http_status(:ok) }

      context 'the response' do
        subject { json[:subjects] }
        it { is_expected.to include(to_map(user1)) }
        it { is_expected.to include(to_map(user2)) }
      end
    end

    context 'delete /api/subjects/:id' do
      def run
        delete "/api/subjects/#{user1.id}", nil, headers
      end

      subject { -> { run } }

      it { is_expected.to change(Subject, :count).by(-1) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
