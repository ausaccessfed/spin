class ProjectsAdminController < ApplicationController
  before_action { @organisation = Organisation.find(params[:organisation_id]) }

  def index
    check_access!("#{access_prefix}:list")
    @projects = @organisation.projects.all
  end

  def new
    check_access!("#{access_prefix}:create")
    @project = @organisation.projects.new
  end

  def create
    check_access!("#{access_prefix}:create")
    @project = @organisation.projects.new(project_params)

    unless @project.save
      return form_error('new', 'Unable to save Project', @project)
    end

    flash[:success] = "Created Project #{@project.name} " \
                       "for #{@organisation.name}"

    redirect_to([@organisation, :projects])
  end

  def edit
    check_access!("#{access_prefix}:update")
    @project = @organisation.projects.find(params[:id])
  end

  def update
    check_access!("#{access_prefix}:update")
    @project = @organisation.projects.find(params[:id])

    unless @project.update_attributes(project_params)
      return form_error('edit', 'Unable to save Project', @project)
    end

    flash[:success] = "Updated Project #{@project.name}" \
                       " for #{@organisation.name}"

    redirect_to([@organisation, :projects])
  end

  def destroy
    check_access!("#{access_prefix}:delete")
    @project = @organisation.projects.find(params[:id])
    @project.destroy!

    flash[:success] = "Deleted Project #{@project.name}"

    redirect_to([@organisation, :projects])
  end

  private

  def project_params
    params.require(:project).permit(:name, :provider_arn, :active)
  end

  def access_prefix
    "organisations:#{@organisation.id}:projects"
  end
end
