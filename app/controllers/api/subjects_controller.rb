module API
  class SubjectsController < APIController
    delegate :image_url, to: :view_context

    def index
      check_access!('api:subjects:list')
      @subjects = Subject.all
    end

    def destroy
      check_access!('api:subjects:delete')
      @object = Subject.find(params[:id])
      @object.destroy!
      render status: :ok, nothing: true
    end

    def create
      check_access!('api:subjects:create')
      validate_required_params
      validate_subject_is_new
      validate_invitation_is_new
      invite_subject
    end

    def show
      check_access!('api:subjects:read')
      @subject = Subject.find(params[:id])
    end

    private

    def invite_subject
      response_map = {}
      Invitation.transaction do
        subject = Subject.create!(subject_attrs)
        invite(subject, response_map) unless subject_attrs.key? :shared_token
        response.headers['Location'] = get_subject_api_path(subject)
        response_map[:subject_id] = subject.id
      end
      render json: response_map, status: :created
    end

    def validate_required_params
      params.require(:name)
      params.require(:mail)
    end

    def subject_attrs
      permitted_params.except(:send_invitation)
    end

    def permitted_params
      params.permit(:mail, :name, :shared_token, :send_invitation)
    end

    def create_invitation(subject)
      identifier = SecureRandom.urlsafe_base64(19)

      attrs = { subject_id: subject.id, identifier: identifier,
                name: subject.name, mail: subject.mail,
                expires: 1.month.from_now }

      Invitation.create!(attrs)
    end

    def invite(subject, response_map)
      invitation = create_invitation(subject)
      if send_invitation_flag
        deliver(invitation)
      else
        response_map[:invitation_url] = invitation_url(invitation)
      end
    end

    def validate_invitation_is_new
      mail_hash = permitted_params.slice(:mail)
      fail(BadRequest, invitation_exists) if Invitation.exists?(mail_hash)
    end

    def validate_subject_is_new
      if permitted_params[:shared_token]
        shared_token_mail_hash = permitted_params.slice(:shared_token, :mail)
        if Subject.exists?(shared_token_mail_hash)
          fail(BadRequest, subject_with_shared_token_exists)
        end
      end
      mail_hash = permitted_params.slice(:mail)
      fail(BadRequest, subject_with_mail_exists) if Subject.exists?(mail_hash)
    end

    def send_invitation_flag
      if permitted_params.key? :send_invitation
        send_inv = permitted_params[:send_invitation]
        return send_inv if bool? send_inv
        fail(BadRequest, invalid_invitation_flag)
      end
      true
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

    def bool?(value)
      [true, false].include? value
    end

    def get_subject_api_path(subject)
      "#{request.base_url}/api/subjects/#{subject.id}"
    end

    def invitation_url(invitation)
      "#{request.base_url}/invitations/#{invitation.identifier}"
    end

    def invitation_exists
      'Invitation with email \'' + permitted_params[:mail] + '\' already exists'
    end

    def invalid_invitation_flag
      'send_invitation param must be boolean (true, false)'
    end

    def subject_with_mail_exists
      'Subject with email \'' + permitted_params[:mail] + '\' already exists'
    end

    def subject_with_shared_token_exists
      'Subject with shared_token \'' + permitted_params[:shared_token] +
        '\' already exists'
    end
  end
end
