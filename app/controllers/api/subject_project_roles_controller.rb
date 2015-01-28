module API
  class SubjectProjectRolesController < APIController
    before_action do
      @organisation = Organisation.find(params[:organisation_id])
      @project = Project.find(params[:project_id])
      @project_role = ProjectRole.find(params[:role_id])
    end

    def create
      check_access!("#{access_prefix}:grant")
      @assoc = @project_role.subject_project_roles.create!(assoc_params)
      render status: :ok, nothing: true
    end

    def destroy
      check_access!("#{access_prefix}:revoke")
      @assoc = @project_role.subject_project_roles.find(params[:id])
      @assoc.destroy!
      render status: :ok, nothing: true
    end

    private

    def assoc_params
      params.require(:subject_project_roles).permit(:subject_id)
    end

    def access_prefix
      "api:organisations:#{@organisation.id}:projects:#{@project.id}:roles"
    end
  end
end
