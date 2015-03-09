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

      context 'with an invite code' do
        let(:invited_user) { create(:subject, complete: false) }
        let!(:invitation) { create(:invitation, subject: invited_user) }
        let(:attrs) { attributes_for(:subject) }
        let(:env) do
          { 'rack.session' => { invite: invitation.identifier },
            'REMOTE_HOST' => remote_host,
            'REMOTE_ADDR' => remote_addr,
            'HTTP_USER_AGENT' => user_agent }
        end

        it 'does not create a subject' do
          expect { subject.subject(env, attrs) }.not_to change(Subject, :count)
        end

        it 'returns the existing subject' do
          expect(subject.subject(env, attrs)).to eq(invitation.subject)
        end

        it 'updates the attributes' do
          expected = attrs.except(:invite, :complete, :audit_comment)
          expect(subject.subject(env, attrs)).to have_attributes(expected)
        end

        it 'completes the subject' do
          expect { subject.subject(env, attrs) }
            .to change { invitation.subject.reload.complete? }.to true
        end

        it 'marks the invite as used' do
          expect { subject.subject(env, attrs) }
            .to change { invitation.reload.used? }.to true
        end

        it 'records an audit record' do
          expect { subject.subject(env, attrs) }
            .to change(Audited.audit_class, :count).by_at_least(1)
        end

        context 'when the invitation fails to save' do
          before do
            allow_any_instance_of(Invitation).to receive(:update_attributes!)
              .and_raise('an failure')
          end

          it 'preserves the subject' do
            expect { subject.subject(env, attrs) }
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
            expect { subject.subject(env, attrs) }
              .to raise_error(/an failure/)
              .and not_change { invitation.reload.attributes }
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
    end
  end
end
