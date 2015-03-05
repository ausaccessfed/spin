require 'rails_helper'

module API
  RSpec.describe SubjectsController, type: :request do
    let(:api_subject) { create(:api_subject, :authorized) }
    let(:headers) { { 'HTTP_X509_DN' => "CN=#{api_subject.x509_cn}" } }
    let!(:user1) { create(:subject) }
    let!(:user2) { create(:subject) }
    let!(:invitation) { create(:invitation, subject: user1) }
    let!(:used_invitation) { create(:invitation, subject: user2, used: true) }

    subject { response }

    context 'get /api/subjects' do
      def to_map(subject)
        subject.attributes.symbolize_keys.slice(:name, :mail, :shared_token,
                                                :id)
      end

      def run
        get '/api/subjects', nil, headers
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

    context 'get /api/subject/:id' do
      def subject_to_map(subject)
        subject_as_map = subject.attributes
                         .symbolize_keys.slice(:name, :mail, :shared_token,
                                               :id, :complete)

        subject_as_map[:created_at] = subject.created_at.iso8601
        subject_as_map[:updated_at] = subject.updated_at.iso8601
        subject_as_map
      end

      def invitation_to_map(invitation)
        invitation_as_map = {}
        invitation_as_map[:invitation_url] =
            "#{request.base_url}/invitations/#{invitation.identifier}"
        invitation_as_map[:invitation_created_at] =
            invitation.created_at.iso8601
        invitation_as_map
      end

      context 'user with invitations' do
        def run
          get "/api/subjects/#{user1.id}", nil, headers
        end

        let(:json) { JSON.parse(response.body, symbolize_names: true) }
        before { run }
        it { is_expected.to have_http_status(:ok) }

        context 'the response' do
          context 'subject' do
            subject { json[:subject] }
            it { is_expected.to eq(subject_to_map(user1)) }
          end
          context 'invitations' do
            subject { json[:invitations] }
            it { is_expected.to eq([invitation_to_map(invitation)]) }
          end
        end
      end

      context 'user without invitations' do
        def run
          get "/api/subjects/#{user2.id}", nil, headers
        end

        let(:json) { JSON.parse(response.body, symbolize_names: true) }
        before { run }
        it { is_expected.to have_http_status(:ok) }

        context 'the response' do
          context 'subject' do
            subject { json[:subject] }
            it { is_expected.to eq(subject_to_map(user2)) }
          end
          context 'invitations' do
            subject { json[:invitations] }
            it { is_expected.to eq([]) }
          end
        end
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
