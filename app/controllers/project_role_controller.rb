class ProjectRoleController < ApplicationController
  before_action do
    @organisation = Organisation.find(params[:organisation_id])
    @project = Project.find(params[:project_id])
  end

  def index
    check_access!("#{access_prefix}:list")

    project_roles_scope = @project.project_roles.all

    if params[:filter].present?
      project_roles_scope = project_roles_scope.filter(params[:filter])
    end

    @filter = params[:filter]
    @project_roles = smart_listing_create(:project_role, project_roles_scope,
                                          partial: 'project_role/listing',
                                          default_sort: { name: 'asc' })
  end

  def new
    check_access!("#{access_prefix}:create")
    @project_role = @project.project_roles.new
  end

  def create
    check_access!("#{access_prefix}:create")
    @project_role = @project.project_roles.new(project_params)

    unless @project_role.save
      return form_error('new', 'Unable to create Project Role', @project_role)
    end

    flash[:success] = "Created Project Role #{@project_role.name}"

    redirect_to([@organisation, @project, :roles])
  end

  def edit
    check_access!("#{access_prefix}:update")
    @project_role = @project.project_roles.find(params[:id])
  end

  def update
    check_access!("#{access_prefix}:update")
    @project_role = @project.project_roles.find(params[:id])
    unless @project_role.update_attributes(project_params)
      return form_error('edit', 'Unable to save Project Role', @project_role)
    end

    flash[:success] = "Updated Project Role #{@project_role.name}"

    redirect_to([@organisation, @project, :roles])
  end

  def show
    check_access!("#{access_prefix}:read")
    @project_role = @project.project_roles.find(params[:id])
  end

  def destroy
    check_access!("#{access_prefix}:delete")
    @project_role = @project.project_roles.find(params[:id])
    @project_role.destroy!

    flash[:success] = "Deleted Project Role #{@project_role.name} \
                       from #{@project.name}"

    redirect_to([@organisation, @project, :roles])
  end

  private

  def project_params
    params.require(:project_role).permit(:name, :role_arn, :state)
  end

  def access_prefix
    "organisations:#{@organisation.id}:projects:#{@project.id}:roles"
  end
end
