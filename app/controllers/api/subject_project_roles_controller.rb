module API
  class SubjectProjectRolesController < APIController
    before_action do
      @organisation = Organisation.find(params[:organisation_id])
      @project = Project.find(params[:project_id])
      @project_role = ProjectRole.find(params[:role_id])
    end

    def create
      check_access!("#{access_prefix}:grant")
      subj_id = assoc_params[:subject_id]
      subject = Subject.find_by_id(subj_id)
      if subject.nil?
        subject_not_found_response(subj_id)
      else
        @assoc = @project_role.subject_project_roles.create!(assoc_params)
        render status: :created, nothing: true
      end
    end

    def destroy
      check_access!("#{access_prefix}:revoke")
      subj_id = params[:id]
      subject = Subject.find_by_id(subj_id)
      if subject.nil?
        subject_not_found_response(subj_id)
      else
        destroy_subject_project_role_association(subj_id)
      end
    end

    private

    def destroy_subject_project_role_association(subj_id)
      @assoc = @project_role.subject_project_roles.find_by_subject_id(subj_id)
      if @assoc.nil?
        role_not_granted_response(subj_id)
      else
        @assoc.destroy!
        render status: :ok, nothing: true
      end
    end

    def role_not_granted_response(subj_id)
      precondition_failed(role_not_granted_error(subj_id))
    end

    def subject_not_found_response(subj_id)
      precondition_failed(subject_not_found_error(subj_id))
    end

    def role_not_granted_error(subject_id)
      "Role #{ @project_role.id } is not granted to Subject #{subject_id}"
    end

    def subject_not_found_error(subject_id)
      "Subject #{subject_id} not found"
    end

    def assoc_params
      params.require(:subject_project_roles).permit(:subject_id)
    end

    def access_prefix
      "api:organisations:#{@organisation.id}:projects:#{@project.id}:roles"
    end
  end
end
