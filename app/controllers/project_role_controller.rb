class ProjectRoleController < ApplicationController
  before_action do
    @organisation = Organisation.find(params[:organisation_id])
    @project = Project.find(params[:project_id])
  end

  def index
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:list")
    @project_roles = @project.project_roles.all
  end

  def new
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:create")
    @project_role = @project.project_roles.new
  end

  def create
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:create")
    @project_role = @project.project_roles.new(project_params)

    unless @project_role.save
      return form_error('new', 'Unable to create Project Role', @project_role)
    end

    flash[:success] = "Created Project Role #{@project_role.name}"

    redirect_to([@organisation, @project, :roles])
  end

  def edit
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:update")
    @project_role = @project.project_roles.find(params[:id])
  end

  def update
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:update")
    @project_role = @project.project_roles.find(params[:id])
    unless @project_role.update_attributes(project_params)
      return form_error('edit', 'Unable to save Project Role', @project_role)
    end

    flash[:success] = "Updated Project Role #{@project_role.name}"

    redirect_to([@organisation, @project, :roles])
  end

  def show
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:read")
    @project_role = @project.project_roles.find(params[:id])
  end

  def destroy
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:delete")
    @project_role = @project.project_roles.find(params[:id])
    @project_role.destroy!

    flash[:success] = "Deleted Project Role #{@project_role.name} \
                       from #{@project.name}"

    redirect_to([@organisation, @project, :roles])
  end

  private

  def project_params
    params.require(:project_role).permit(:name, :aws_identifier, :state)
  end
end
