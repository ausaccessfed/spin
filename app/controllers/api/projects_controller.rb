module API
  class ProjectsController < APIController
    before_action do
      @organisation = Organisation
                      .find(params[:organisation_id])
    end
    def create
      check_access!("#{access_prefix}:create")
      @project = @organisation.projects.create!(project_params)
      render status: :ok, plain: "Project #{@project.id} created"
    end

    def update
      check_access!("#{access_prefix}:update")
      project_id = params[:id]
      @project = @organisation.projects.find(project_id)
      @project.update_attributes!(project_params)
      render status: :ok, plain: "Project #{project_id} updated"
    end

    def index
      check_access!("#{access_prefix}:list")
      @projects = @organisation.projects.all
    end

    def destroy
      check_access!("#{access_prefix}:delete")
      project_id = params[:id]
      @project = @organisation.projects.find(project_id)
      @project.destroy!
      render status: :ok, plain: "Project #{project_id} deleted"
    end

    private

    def project_params
      params.require(:project).permit(:name, :provider_arn, :state, :id)
    end

    def access_prefix
      "api:organisations:#{@organisation.id}:projects"
    end
  end
end
