require 'rails_helper'

module Authentication
  RSpec.describe SubjectReceiver do
    subject(:receiver) { SubjectReceiver.new }
    let(:env) { {} }

    context '#map_attributes' do
      let(:attrs) do
        keys = %w(edupersontargetedid auedupersonsharedtoken displayname mail)
        keys.reduce({}) { |a, e| a.merge(e => e) }
      end

      it 'maps the attributes' do
        expect(receiver.map_attributes(env, attrs))
          .to eq(name: 'displayname',
                 mail: 'mail',
                 shared_token: 'auedupersonsharedtoken',
                 targeted_id: 'edupersontargetedid')
      end
    end

    context '#subject' do
      let(:attributes) { attributes_for(:subject) }
      let(:updated_attributes) do
        attributes.merge(name: Faker::Name.name,
                         mail: Faker::Internet.email)
      end

      let(:remote_host) { Faker::Internet.url }
      let(:remote_addr) { Faker::Internet.ip_v4_address }
      let(:user_agent) { Faker::Lorem.characters }

      context 'with mocked http session vars' do
        let(:env) do
          { 'REMOTE_HOST' => remote_host,
            'REMOTE_ADDR' => remote_addr,
            'HTTP_USER_AGENT' => user_agent }
        end

        subject { receiver.subject(env, attributes) }

        it 'changes the SubjectSession count' do
          expect { subject }
            .to change(SubjectSession, :count).by(1)
        end

        it 'contains the fields from the http session' do
          receiver.subject(env, attributes)

          expect(SubjectSession.last)
            .to have_attributes(id: SubjectSession.last.id,
                                remote_host: remote_host,
                                remote_addr: remote_addr,
                                http_user_agent: user_agent,
                                subject_id: subject.id)
        end

        context 'without an existing Subject' do
          it 'stores a new Subject' do
            expect { subject }
              .to change(Subject, :count).by(1)
          end

          it { is_expected.to be_a(Subject) }
          it { is_expected.to have_attributes(attributes) }
        end

        context 'with an existing Subject' do
          let!(:created_subject) { receiver.subject(env, attributes) }
          subject { receiver.subject(env, updated_attributes).reload }

          it { is_expected.to eq(created_subject) }
          it { is_expected.to have_attributes(updated_attributes) }
        end

        context 'when the SubjectSession fails to save' do
          let(:SubjectSession) { double }

          context 'with an existing Subject' do
            let!(:created_subject) { receiver.subject(env, attributes) }
            before do
              allow(SubjectSession)
                .to receive(:create!)
                .and_raise('a failure')
            end

            subject { receiver.subject(env, updated_attributes).reload }

            it 'preserves the subject' do
              expect { subject }
                .to raise_error(/a failure/)
                .and not_change { Subject.last.reload.attributes }
            end

            it 'does not create a new subject' do
              expect { subject }
                .to raise_error(/a failure/)
                .and not_change(Subject, :count)
            end
          end

          context 'with no existing Subject' do
            before do
              allow(SubjectSession)
                .to receive(:create!)
                .and_raise('a failure')
            end

            it 'does not create a new subject' do
              expect { subject }
                .to raise_error(/a failure/)
                .and not_change(Subject, :count)
            end
          end
        end
      end

      context 'with an invitation' do
        let(:invited_user) do
          create(:subject, complete: false, shared_token: nil, targeted_id: nil)
        end
        let!(:invitation) { create(:invitation, subject: invited_user) }
        let(:attrs) { attributes_for(:subject) }
        let(:env) do
          { 'rack.session' => { invite: invitation.identifier },
            'REMOTE_HOST' => remote_host,
            'REMOTE_ADDR' => remote_addr,
            'HTTP_USER_AGENT' => user_agent }
        end

        def run
          receiver.subject(env, attrs)
        end

        subject { run }

        it 'does not create a subject' do
          expect { subject }.not_to change(Subject, :count)
        end

        it 'returns the existing subject' do
          expect(subject).to eq(invitation.subject)
        end

        it 'updates the attributes' do
          expected = attrs.except(:invite, :complete, :audit_comment)
          expect(subject).to have_attributes(expected)
        end

        it 'completes the subject' do
          expect { subject }
            .to change { invitation.subject.reload.complete? }.to true
        end

        it 'marks the invite as used' do
          expect { subject }
            .to change { invitation.reload.used? }.to true
        end

        it 'records an audit record' do
          expect { subject }
            .to change(Audited.audit_class, :count).by_at_least(1)
        end

        context 'when the invitation fails to save' do
          before do
            allow_any_instance_of(Invitation).to receive(:update_attributes!)
              .and_raise('an failure')
          end

          it 'preserves the subject' do
            expect { subject }
              .to raise_error(/an failure/)
              .and not_change { invitation.subject.reload.attributes }
          end
        end

        context 'when the subject fails to save' do
          before do
            allow_any_instance_of(Subject).to receive(:update_attributes!)
              .and_raise('an failure')
          end

          it 'preserves the invite' do
            expect { subject }
              .to raise_error(/an failure/)
              .and not_change { invitation.reload.attributes }
          end
        end

        context 'that has already been accepted' do
          let(:accepted_user) { create(:subject, complete: true) }
          let!(:invitation) do
            create(:invitation, subject: accepted_user, used: true)
          end
          let(:new_name) { Faker::Name.name }
          let(:attrs) do
            { targeted_id: accepted_user.targeted_id,
              shared_token: accepted_user.shared_token,
              name: new_name,
              mail: accepted_user.mail }
          end

          subject { -> { run } }

          it 'does not create a subject' do
            expect(subject).not_to change(Subject, :count)
          end

          it 'does not modify invitations' do
            expect(subject).not_to change(Invitation, :count)
          end

          context 'the result' do
            subject { run }
            it 'is the existing subject' do
              expect(subject).to eq(accepted_user)
            end

            it 'has attributes updated' do
              expected = attrs.except(:invite, :complete, :audit_comment)
              expect(subject).to have_attributes(expected)
            end
          end
        end

        context 'when the subject already exists' do
          include_context 'projects'

          let(:completed_user) { create(:subject, mail: 'bbeddoes@uq.edu.au') }
          let(:invited_user) do
            create(:subject,
                   mail: 'bradleybeddoes@gmail',
                   complete: false,
                   shared_token: nil,
                   targeted_id: nil)
          end
          let(:attrs) do
            { targeted_id: completed_user.targeted_id,
              shared_token: completed_user.shared_token,
              name: completed_user.name,
              mail: completed_user.mail }
          end

          let!(:subject_project_role_for_invited_user) do
            create_subject_project_role_for_active_project(invited_user)
          end

          before { run }

          shared_examples 'a merge operation' do
            context 'invited subject record' do
              subject { invited_user }
              it 'is deleted' do
                expect(Subject.exists?(subject)).to be_falsey
              end

              it 'has a merge audit message' do
                messages = []
                subject.audits.each do |audit|
                  messages << audit.comment if audit.comment
                end
                expect(messages).to include('Merging from Subject'\
                           " #{invited_user.id} to #{completed_user.id}")
              end
            end

            context 'subject project role for invited user' do
              subject { subject_project_role_for_invited_user }
              it 'is deleted' do
                expect(SubjectProjectRole.exists?(subject)).to be_falsey
              end
            end

            context 'the completed user' do
              subject { completed_user }
              it 'exists' do
                expect(Subject.exists?(subject)).to be_truthy
              end

              context 'invitations' do
                subject { completed_user.invitations }
                it 'are now associated' do
                  expect(subject).to eq([invitation])
                end

                it 'has a merge audit message' do
                  messages = []
                  subject.last.audits.each do |audit|
                    messages << audit.comment if audit.comment
                  end
                  expect(messages).to include('Merging from Subject'\
                           " #{invited_user.id} to #{completed_user.id}")
                end
              end

              context 'the new subject_project_roles' do
                let(:lookup_map) do
                  { subject_id: completed_user.id,
                    project_role_id: subject_project_role_for_invited_user
                      .project_role.id }
                end

                subject { SubjectProjectRole.find_by(lookup_map) }
                it 'is not nil' do
                  expect(subject).to_not be_nil
                end

                it 'has a merge audit message' do
                  messages = []
                  subject.audits.each do |audit|
                    messages << audit.comment if audit.comment
                  end
                  expect(messages).to include('Merging from Subject'\
                           " #{invited_user.id} to #{completed_user.id}")
                end
              end
            end
          end

          it_behaves_like 'a merge operation'

          context 'with no shared_token' do
            let(:completed_user) do
              create(:subject, complete: false, shared_token: nil)
            end

            let(:attrs) do
              { targeted_id: completed_user.targeted_id,
                shared_token: attributes_for(:subject)[:shared_token],
                name: completed_user.name,
                mail: completed_user.mail }
            end

            it_behaves_like 'a merge operation'
          end

          context 'with no targeted_id' do
            let(:completed_user) do
              create(:subject, complete: false, targeted_id: nil)
            end

            let(:attrs) do
              { targeted_id: attributes_for(:subject)[:targeted_id],
                shared_token: completed_user.shared_token,
                name: completed_user.name,
                mail: completed_user.mail }
            end

            it_behaves_like 'a merge operation'
          end
        end
      end
    end

    context 'after authenticating with idP' do
      include_context 'projects'

      let!(:user) { create(:subject) }
      let(:env) { { 'rack.session' => { 'subject_id' => user.id } } }

      subject { receiver.finish(env) }

      context 'with no projects' do
        it 'redirects to no projects assigned page' do
          expect(subject).to eq([302, { 'Location' => '/dashboard' }, []])
        end
      end

      context 'with 1 project' do
        before { create_subject_project_role_for_active_project(user) }
        it 'redirects to aws auth' do
          expect(subject).to eq([302, { 'Location' => '/aws_login' }, []])
        end
      end

      context 'with more than 1 project' do
        before do
          3.times { create_subject_project_role_for_active_project(user) }
        end

        it 'redirects to projects page' do
          expect(subject).to eq([302, { 'Location' => '/projects' }, []])
        end
      end

      context 'with admin permissions and 1 active project' do
        let!(:user) { create(:subject, :authorized) }
        before { create_subject_project_role_for_active_project(user) }
        it 'redirects to dashboard page' do
          expect(subject).to eq([302, { 'Location' => '/dashboard' }, []])
        end
      end

      context 'with the invite flag set' do
        before { receiver.finish(env) }
        let(:env) do
          { 'rack.session' =>
                { 'subject_id' => user.id,
                  invite: SecureRandom.urlsafe_base64(19) }
          }
        end
        it 'is reset' do
          expect(env['rack.session'].key?(:invite)).to be_falsey
        end
      end
    end
  end
end
