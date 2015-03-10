module CreateInvitation
  NEW_INVITATION_BODY_FILE = 'config/new_invitation_body.txt'
  NEW_INVITATION_EMAIL_BODY = Rails.root.join(NEW_INVITATION_BODY_FILE).read

  delegate :image_url, to: :view_context

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
                 subject: new_invitation_message,
                 body: email_message(invitation).render,
                 content_type: 'text/html; charset=UTF-8')
    invitation.touch(:last_email_sent_at)
    self
  end

  def email_message(invitation)
    Lipstick::EmailMessage.new(title: new_invitation_message,
                               image_url: image_url('email_branding.png'),
                               content: email_body(invitation))
  end

  def new_invitation_message
    "Invitation to #{SpinEnvironment.environment_string}"
  end

  def email_body(invitation)
    format(NEW_INVITATION_EMAIL_BODY,
           url: accept_invitations_url(identifier: invitation.identifier),
           environment_string: SpinEnvironment.environment_string)
  end
end
