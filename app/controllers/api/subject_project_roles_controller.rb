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
      return precondition_failed(subject_not_found(subj_id)) if subject.nil?
      @assoc = @project_role.subject_project_roles.create!(assoc_params)
      render status: :ok, nothing: true
    end

    def destroy
      check_access!("#{access_prefix}:revoke")
      subj_id = params[:id]
      subject = Subject.find_by_id(subj_id)
      return precondition_failed(subject_not_found(subj_id)) if subject.nil?
      @assoc = @project_role.subject_project_roles.find_by_subject_id(subj_id)
      return precondition_failed(role_not_granted(subj_id)) if @assoc.nil?
      @assoc.destroy!
      render status: :ok, nothing: true
    end

    private

    def role_not_granted(subject_id)
      "Role #{ @project_role.id } is not granted to Subject #{subject_id}"
    end

    def subject_not_found(subject_id)
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
