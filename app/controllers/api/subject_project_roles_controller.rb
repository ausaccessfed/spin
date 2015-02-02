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

      return subject_not_found_response(subj_id) if subject.nil?

      @assoc = @project_role.subject_project_roles.build(assoc_params)
      return render status: :precondition_failed,
                    plain: error_from_validations(@assoc) unless @assoc.save

      render status: :ok, plain: "Subject #{subj_id} granted"
    end

    def destroy
      check_access!("#{access_prefix}:revoke")
      subj_id = params[:id]
      subject = Subject.find_by_id(subj_id)

      return subject_not_found_response(subj_id) if subject.nil?

      @assoc = @project_role.subject_project_roles.find_by_subject_id(subj_id)

      return render status: :precondition_failed,
                    plain: role_not_granted(subj_id) if @assoc.nil?

      @assoc.destroy!

      render status: :ok, plain: "Subject #{subj_id} revoked"
    end

    private

    def role_not_granted(subject_id)
      "Role #{ @project_role.id } is not granted to Subject #{subject_id}"
    end

    def subject_not_found_response(subject_id)
      render status: :precondition_failed,
             plain: "Subject #{subject_id} not found"
    end

    def assoc_params
      params.require(:subject_project_roles).permit(:subject_id)
    end

    def access_prefix
      "api:organisations:#{@organisation.id}:projects:#{@project.id}:roles"
    end
  end
end
