require 'rails_helper'

module API
  RSpec.describe SubjectsController, type: :controller do
    let(:api_subject) do
      role = create(:role)
      user = create(:api_subject, :authorized, permission: 'api:subjects:*')
      create(:api_subject_role, role: role, api_subject: user)
      user
    end

    before { request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" }
    subject { response }

    context 'get :index' do
      before { get :index, format: 'json' }

      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api/subjects/index') }

      it 'assigns the subjects' do
        expect(assigns[:subjects]).to eq(Subject.all)
      end

      context 'as a non-privileged user' do
        let(:api_subject) { create(:api_subject) }

        it { is_expected.to have_http_status(:forbidden) }

        it 'responds with a message' do
          data = JSON.load(response.body)
          expect(data['message']).to match(/explicitly denied/)
        end
      end
    end

    context 'delete :id' do
      def run
        delete :destroy, id: object.id, format: 'json'
      end

      let!(:object) { create(:subject) }

      subject { -> { run } }

      it { is_expected.to change(Subject, :count).by(-1) }
      it { is_expected.to have_assigned(:object, object) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'post :create' do
      let(:shared_token) { SecureRandom.urlsafe_base64(16) }
      let(:name) { Faker::Name.name }
      let(:mail) { Faker::Internet.email }

      def run
        post :create, params
      end

      subject { -> { run } }

      context 'with missing name param' do
        let(:params) { { mail: mail } }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:bad_request) }
          context 'body' do
            subject { response.body }
            it 'describes the error' do
              is_expected.to eq("{\"error\":\"Validation failed:" \
               " Name can't be blank\"}")
            end
          end
        end
      end

      context 'with missing mail param' do
        let(:params) { { name: name } }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:bad_request) }
          context 'body' do
            subject { response.body }
            it 'describes the error' do
              is_expected.to eq("{\"error\":\"Validation failed: " \
                "Mail can't be blank\"}")
            end
          end
        end
      end

      context 'with malformed send_invitation flag' do
        let(:params) do
          { name: name,
            mail: mail,
            send_invitation: Faker::Lorem.characters }
        end

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:bad_request) }
          context 'body' do
            subject { response.body }
            it 'describes the error' do
              is_expected.to eq("{\"message\":\"The request parameters could" \
              " not be successfully processed.\",\"error\":\"" \
              "send_invitation param must be boolean (true, false)\"}")
            end
          end
        end
      end

      context 'with name, mail and send_invitation = true (default)' do
        let(:params) { { name: name, mail: mail } }

        context 'when a subject with the email already exists' do
          let!(:user) { create(:subject) }
          let(:mail) { user.mail }

          it { is_expected.to change(Subject, :count).by(0) }

          context 'the invitiation' do
            before { run }
            it 'is not sent' do
              expect(response).to_not have_sent_email.to(mail)
            end
          end

          context 'the response' do
            before { run }
            subject { response }
            it { is_expected.to have_http_status(:bad_request) }
            context 'body' do
              subject { response.body }
              it 'describes the error' do
                is_expected.to eq("{\"error\":\"Validation failed:" \
                  " Mail has already been taken\"}")
              end
            end
          end
        end

        context 'no existing subjects with the email are present' do
          let(:mail) { Faker::Internet.email }

          it { is_expected.to change(Subject, :count).by(1) }
          it { is_expected.to change(Invitation, :count).by(1) }

          context 'the invitiation' do
            before { run }
            it 'is sent' do
              expect(response).to have_sent_email.to(mail)
            end
          end

          context 'the created Subject' do
            before { run }
            subject { Subject.last }

            it 'is expected to be associated with an invitation' do
              expect(subject.invitations).to eq([Invitation.last])
            end
          end

          context 'the response' do
            before { run }
            subject { response }

            it { is_expected.to have_http_status(:created) }

            context 'headers' do
              subject { response.headers }
              it 'contains the new resource' do
                expect(subject).to include('Location' => "#{request.base_url}" \
                  "/api/subjects/#{Subject.last.id}")
              end
            end

            context 'body' do
              subject { response.body }
              it 'contains the new subject_id' do
                expect(subject).to include("\"subject_id\":#{Subject.last.id}")
              end
            end
          end
        end

        context 'an invitation for the email already exists' do
          let!(:invitation) { create(:invitation, mail: mail) }
          let(:mail) { Faker::Internet.email }

          it { is_expected.to change(Subject, :count).by(0) }
          it { is_expected.to change(Invitation, :count).by(0) }

          context 'the response' do
            before { run }
            subject { response }
            it { is_expected.to have_http_status(:bad_request) }
            context 'body' do
              subject { response.body }
              it 'describes the error'do
                is_expected.to eq("{\"message\":\"The request parameters"\
                " could not be successfully processed.\",\"error\":\"The"\
                " user '#{invitation.name}' has already received an invite. "\
                "If you can't find that user in the system, they may have a "\
                'different email address associated with their SPIN'\
                " account.\"}")
              end
            end
          end
        end
      end

      context 'with name, mail and send_invitation = false' do
        let(:params) { { name: name, mail: mail, send_invitation: false } }

        context 'when no subjects with the email are present' do
          let(:mail) { Faker::Internet.email }

          it { is_expected.to change(Subject, :count).by(1) }
          it { is_expected.to change(Invitation, :count).by(1) }

          context 'the invitiation' do
            before { run }
            it 'is not sent' do
              expect(response).to_not have_sent_email.to(mail)
            end
          end

          context 'the created Subject' do
            before { run }
            subject { Subject.last }

            it 'is expected to be associated with an invitation' do
              expect(subject.invitations).to eq([Invitation.last])
            end
          end

          context 'the response' do
            before { run }
            subject { response }
            it { is_expected.to have_http_status(:created) }

            context 'headers' do
              subject { response.headers }
              it 'contains the new resource' do
                is_expected.to include('Location' => "#{request.base_url}" \
                  "/api/subjects/#{Subject.last.id}")
              end
            end

            context 'body' do
              subject { response.body }
              it 'contains the new subject_id' do
                expect(subject).to include("\"subject_id\":#{Subject.last.id}")
              end
              it 'contains the invitation_url' do
                expect(subject).to include("\"invitation_url\":" \
                  "\"http://test.host/invitations/" \
                  "#{Invitation.last.identifier}\"")
              end
            end
          end
        end
      end

      context 'with name, mail and shared_token' do
        let(:params) { { name: name, mail: mail, shared_token: shared_token } }

        context 'when a subject with the shared_token & mail already exists' do
          let!(:user) { create(:subject) }
          let(:shared_token) { user.shared_token }
          let(:mail) { user.mail }

          it { is_expected.to change(Subject, :count).by(0) }

          context 'the invitiation' do
            before { run }
            it 'is not sent' do
              expect(response).to_not have_sent_email.to(mail)
            end
          end

          context 'the response' do
            before { run }
            subject { response }
            it { is_expected.to have_http_status(:bad_request) }
            context 'body' do
              subject { response.body }
              it 'describes the error' do
                is_expected.to eq("{\"error\":\"Validation failed: Mail has" \
                " already been taken, Shared token has already been taken\"}")
              end
            end
          end
        end

        context 'when no subjects with the shared_token are present' do
          let(:shared_token) { SecureRandom.urlsafe_base64(16) }

          it { is_expected.to change(Subject, :count).by(1) }
          it { is_expected.to change(Invitation, :count).by(0) }

          it 'did not email an invitation' do
            expect(response).to_not have_sent_email.to(mail)
          end

          context 'the created Subject' do
            before { run }
            subject { Subject.last }

            it 'is expected to have shared_token' do
              expect(subject.shared_token).to eq(shared_token)
            end

            it 'is expected to not be associated with an invitation' do
              expect(subject.invitations).to eq([])
            end
          end

          context 'the response' do
            before { run }
            subject { response }
            it { is_expected.to have_http_status(:created) }

            context 'headers' do
              subject { response.headers }
              it 'contains the new resource' do
                is_expected.to include('Location' => "#{request.base_url}" \
                  "/api/subjects/#{Subject.last.id}")
              end
            end

            context 'body' do
              subject { response.body }
              it 'contains the new subject_id' do
                expect(subject).to include("\"subject_id\":#{Subject.last.id}")
              end
            end
          end
        end
      end
    end

    context 'show :id' do
      let!(:user) { create(:subject) }

      def run
        get :show, id: user.id, format: 'json'
      end

      subject { -> { run } }

      it { is_expected.to have_assigned(:subject, user) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end
  end
end
