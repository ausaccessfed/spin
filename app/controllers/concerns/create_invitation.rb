module CreateInvitation
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
                 subject: 'Invitation to SPIN',
                 body: email_message(invitation).render,
                 content_type: 'text/html; charset=UTF-8')
    invitation.touch(:last_email_sent_at)
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
    |Regards
  EOF

  def email_body(invitation)
    format(EMAIL_BODY,
           url: accept_invitations_url(identifier: invitation.identifier))
  end
end
