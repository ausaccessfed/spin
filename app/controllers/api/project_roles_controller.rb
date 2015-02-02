module API
  class ProjectRolesController < APIController
    before_action do
      @organisation = Organisation
                      .find(params[:organisation_id])
      @project = Project.find(params[:project_id])
    end
    def create
      check_access!("#{access_prefix}:create")
      @project_role = @project.project_roles.create!(project_role_params)
      render status: :ok, plain: "ProjectRole #{@project_role.id} created"
    end

    def update
      check_access!("#{access_prefix}:update")
      project_role_id = params[:id]
      @project_role = @project.project_roles.find(project_role_id)
      @project_role.update_attributes!(project_role_params)
      render status: :ok, plain: "ProjectRole #{project_role_id} updated"
    end

    def index
      check_access!("#{access_prefix}:list")
      @project_roles = @project.project_roles.all
    end

    def destroy
      check_access!("#{access_prefix}:delete")
      project_role_id = params[:id]
      @project_role = @project.project_roles.find(project_role_id)
      @project_role.destroy!
      render status: :ok, plain: "ProjectRole #{project_role_id} deleted"
    end

    private

    def project_role_params
      params.require(:project_role).permit(:name, :role_arn, :id)
    end

    def access_prefix
      "api:organisations:#{@organisation.id}:projects:#{@project.id}"
    end
  end
end
