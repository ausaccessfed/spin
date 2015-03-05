class SubjectProjectRoleInvitationsController < ApplicationController
  delegate :image_url, to: :view_context

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
    Invitation.transaction do
      subject = Subject.find_by_mail(invitation_params[:mail])
      if subject.nil?
        subject = Subject.new(invitation_params.except(:send_invitation))
        unless subject.save
          flash[:error] = "#{error_from_validations(subject)}"
          return redirect_to(project_role_path)
        end

        invitation = create_invitation(subject)
        if send_invitation_flag
          deliver(invitation)
          flash[:success] = "#{subject_added} #{email_has_been_sent(subject)}"
        else
          flash[:success] = "#{subject_added} #{activation_message(invitation_url(invitation))}"
        end
      else
        flash[:success] = "#{subject_added}"
      end

      @assoc = @project_role.subject_project_roles.build(subject_id: subject.id)
      unless @assoc.save
        flash[:error] = "#{error_from_validations(@assoc)}"
        return redirect_to(project_role_path)
      end
    end

    redirect_to(project_role_path)
  end

  def check_required_params(params)
    params.each do |param|
      unless invitation_params.key? param
        fail(BadRequest, "missing required parameter #{param}")
      end
    end
  end

  private

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
    "Activate the account here: #{url}." if url
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

  def create_invitation(subject)
    identifier = SecureRandom.urlsafe_base64(19)

    attrs = { subject_id: subject.id, identifier: identifier,
              name: subject.name, mail: subject.mail,
              expires: 1.month.from_now }

    Invitation.create!(attrs)
  end

  def deliver(invitation)
    Mail.deliver(to: invitation.mail,
                 from: Rails.application.config.spin_service.mail[:from],
                 subject: 'Invitation to SPIN',
                 body: email_message(invitation).render,
                 content_type: 'text/html; charset=UTF-8')

    self
  end

  def email_message(invitation)
    Lipstick::EmailMessage.new(title: 'SPIN',
                               image_url: image_url('email_branding.png'),
                               content: email_body(invitation))
  end

  EMAIL_BODY = <<-EOF.gsub(/^\s+\|/, '')
    |You have been invited to SPIN.
    |
    |Please visit the following link to accept the invite and get started:
    |
    |%{url}
    |
    |Regards,<br/>
    |AAF Team
  EOF

  def email_body(_invitation)
    format(EMAIL_BODY, url: '')
  end

  def invitation_url(invitation)
    "#{request.base_url}/invitations/#{invitation.identifier}"
  end
end
