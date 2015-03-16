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
      response_map = {}
      Invitation.transaction do
        subject = Subject.create!(subject_attrs)
        invite(subject, response_map) unless subject_attrs.key? :shared_token
        response.headers['Location'] = get_subject_api_path(subject)
        response_map[:subject_id] = subject.id
      end
      render json: response_map, status: :created
    end

    def show
      check_access!('api:subjects:read')
      @subject = Subject.find(params[:id])
    end

    private

    def subject_attrs
      permitted_params.except(:send_invitation)
    end

    def permitted_params
      params.permit(:mail, :name, :shared_token, :send_invitation)
    end

    def invite(subject, response_map)
      if invitation_exists?(subject[:mail])
        fail(BadRequest, invitation_exists_error(subject[:mail]))
      end

      invitation = create_invitation(subject)
      if send_invitation_flag
        deliver(invitation)
      else
        response_map[:invitation_url] =
            accept_invitations_url(identifier: invitation.identifier)
      end
    end

    def send_invitation_flag
      return true unless permitted_params.key?(:send_invitation)
      send_inv = permitted_params[:send_invitation]
      return send_inv if bool? send_inv
      fail(BadRequest, invalid_invitation_flag)
    end

    def bool?(value)
      [true, false].include? value
    end

    def get_subject_api_path(subject)
      "#{request.base_url}/api/subjects/#{subject.id}"
    end

    def invalid_invitation_flag
      'send_invitation param must be boolean (true, false)'
    end
  end
end
