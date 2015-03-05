module API
  class SubjectsController < APIController
    include CreateInvitation

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

    def bool?(value)
      [true, false].include? value
    end

    def get_subject_api_path(subject)
      "#{request.base_url}/api/subjects/#{subject.id}"
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
