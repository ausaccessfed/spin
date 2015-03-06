class SubjectProjectRoleInvitationsController < ApplicationController
  include CreateInvitation

  before_action do
    @organisation = Organisation.find(params[:organisation_id])
    @project = Project.find(params[:project_id])
    @project_role = ProjectRole.find(params[:role_id])
  end

  def new
    check_access!("#{access_prefix}:grant")
    @invitation = Invitation.new
  end

  def create
    check_access!("#{access_prefix}:grant")
    invite_and_associate_with_project
    redirect_to(project_role_path)
  end

  private

  def invite_and_associate_with_project
    Invitation.transaction do
      subject = Subject.find_by_mail(invitation_params[:mail])
      subject = create_and_invite_subject if subject.nil?
      associate_subject_with_project_role(subject)
    end
  end

  def create_and_invite_subject
    subject = Subject.new(invitation_params.except(:send_invitation))
    if !subject.save
      flash[:error] = "#{error_from_validations(subject)}"
    else
      create_and_send_invitation(subject)
    end
    subject
  end

  def associate_subject_with_project_role(subject)
    return unless subject.valid?
    @assoc = @project_role.subject_project_roles.build(subject_id: subject.id)
    if @assoc.save
      flash[:success] = "#{subject_added} #{flash[:success]}"
    else
      flash[:error] = "#{error_from_validations(@assoc)}"
    end
  end

  def create_and_send_invitation(subject)
    invitation = create_invitation(subject)
    if send_invitation_flag
      deliver(invitation)
      flash[:success] = "#{email_has_been_sent(subject)}"
    else
      flash[:success] = "#{activation_message(invitation_url(invitation))}"
    end
  end

  def invitation_params
    params.require(:invitation).permit(:name, :mail, :send_invitation)
  end

  def project_role_path
    organisation_project_role_path(@organisation, @project, @project_role)
  end

  def access_prefix
    "organisations:#{@organisation.id}:projects:#{@project.id}:roles"
  end

  def activation_message(url)
    "Activate the account here: #{url}" if url
  end

  def email_has_been_sent(subject)
    "An email has been sent to #{subject.mail}."
  end

  def subject_added
    "Subject has been added to Project Role '#{@project_role.name}'."
  end

  def send_invitation_flag
    params[:invitation][:send_invitation] == '1'
  end
end
