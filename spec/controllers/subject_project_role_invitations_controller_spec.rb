require 'rails_helper'

RSpec.describe SubjectProjectRoleInvitationsController, type: :controller do
  def permission_string
    "organisations:#{organisation.id}:projects:#{project.id}:*"
  end

  let(:user) { create(:subject, :authorized, permission: permission_string) }
  let(:organisation) { create(:organisation) }
  let(:project) { create(:project, organisation: organisation) }
  let(:project_role) { create(:project_role, project_id: project.id) }
  let(:base_params) do
    { role_id: project_role.id,
      project_id: project.id,
      organisation_id: organisation.id }
  end

  before { session[:subject_id] = user.try(:id) }

  context 'get :new' do
    def run
      get :new, base_params
    end

    subject { -> { run } }

    it { is_expected.to have_assigned(:invitation, an_instance_of(Invitation)) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to have_http_status(:ok) }
      it 'renders template' do
        expect(subject)
          .to render_template('subject_project_role_invitations/new')
      end
    end
  end

  context 'post :create' do
    let(:name) { Faker::Name.name }
    let(:mail) { Faker::Internet.email }
    let(:invitation_params) { { name: name, mail: mail, send_invitation: '1' } }

    def run
      base_params[:invitation] = invitation_params
      post :create, base_params
    end

    subject { -> { run } }

    context 'blank name' do
      let(:invitation_params) { { mail: mail, send_invitation: '1' } }
      before { run }
      it 'sets the flash message' do
        expect(flash[:error]).to eq('Name can\'t be blank')
      end
    end

    context 'blank mail' do
      let(:invitation_params) { { name: name, send_invitation: '1' } }
      before { run }
      it 'sets the flash message' do
        expect(flash[:error]).to eq('Mail can\'t be blank')
      end
    end

    context 'with name, mail and send_invitation = true' do
      let(:invitation_params) do
        { name: name, mail: mail, send_invitation: '1' }
      end

      context 'when a subject with the email already exists' do
        let!(:existing_user) { create(:subject) }
        let(:mail) { existing_user.mail }

        it { is_expected.to change(Subject, :count).by(0) }
        it { is_expected.to change(SubjectProjectRole, :count).by(1) }

        context 'the invitiation' do
          before { run }
          it 'is not sent' do
            expect(response).to_not have_sent_email.to(mail)
          end
        end

        context 'the response' do
          before { run }
          subject { response }
          it 'sets the flash message' do
            expect(flash[:success]).to eq('Subject has been added to ' \
               "Project Role '#{project_role.name}'.")
          end
        end

        context 'already associated with the same project role' do
          let!(:subject_project_role) do
            create(:subject_project_role, project_role: project_role,
                                          subject: existing_user)
          end

          it { is_expected.to change(Subject, :count).by(0) }
          it { is_expected.to change(SubjectProjectRole, :count).by(0) }

          context 'the response' do
            before { run }
            subject { response }
            it 'sets the flash message' do
              expect(flash[:error]).to eq('Subject already has this role' \
               ' granted')
            end
          end
        end
      end

      context 'when no subjects with the email are present' do
        it { is_expected.to change(Subject, :count).by(1) }
        it { is_expected.to change(Invitation, :count).by(1) }
        it { is_expected.to change(SubjectProjectRole, :count).by(1) }

        context 'the invitiation' do
          before { run }
          it 'is sent' do
            expect(response).to have_sent_email.to(mail)
          end
        end

        context 'the response' do
          before { run }
          subject { response }
          it 'sets the flash message' do
            expect(flash[:success]).to eq('Subject has been added to' \
               " Project Role '#{project_role.name}'. An email has been sent" \
               " to #{Subject.last.mail}.")
          end
        end

        context 'the created Subject' do
          before { run }
          subject { Subject.last }

          it 'is expected to be associated with an invitation' do
            expect(subject.invitations).to eq([Invitation.last])
          end

          it 'is expected to be associated with a project' do
            expect(subject.subject_project_roles).to eq([SubjectProjectRole.last])
          end
        end
      end
    end

    context 'with name, mail and send_invitation = false' do
      let(:invitation_params) do
        { name: name, mail: mail, send_invitation: '0' }
      end
      context 'when a subject with the email already exists' do
        let!(:another_user) { create(:subject) }
        let(:mail) { another_user.mail }

        it { is_expected.to change(Subject, :count).by(0) }
        it { is_expected.to change(SubjectProjectRole, :count).by(1) }

        context 'the invitiation' do
          before { run }
          it 'is not sent' do
            expect(response).to_not have_sent_email.to(mail)
          end
        end

        context 'the response' do
          before { run }
          subject { response }
          it 'sets the flash message' do
            expect(flash[:success]).to eq('Subject has been added to ' \
               "Project Role '#{project_role.name}'.")
          end
        end

        context 'already associated with the same project role' do
          let!(:subject_project_role) do
            create(:subject_project_role, project_role: project_role,
                                          subject: another_user)
          end

          it { is_expected.to change(Subject, :count).by(0) }
          it { is_expected.to change(SubjectProjectRole, :count).by(0) }

          context 'the response' do
            before { run }
            subject { response }
            it 'sets the flash message' do
              expect(flash[:error])
                .to eq('Subject already has this role granted')
            end
          end
        end
      end
      context 'when no subjects with the email are present' do
        it { is_expected.to change(Subject, :count).by(1) }
        it { is_expected.to change(Invitation, :count).by(1) }
        it { is_expected.to change(SubjectProjectRole, :count).by(1) }

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

          it 'is expected to be associated with a project' do
            expect(subject.subject_project_roles)
              .to eq([SubjectProjectRole.last])
          end
        end

        context 'the response' do
          before { run }
          subject { response }
          it 'sets the flash message' do
            expect(flash[:success]).to eq('Subject has been' \
           " added to Project Role '#{project_role.name}'." \
           ' Activate the account here: ' \
           "#{request.base_url}/invitations/#{Invitation.last.identifier}.")
          end
        end
      end
    end
  end
end
