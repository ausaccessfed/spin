class ProjectsAdminController < ApplicationController
  before_action { @organisation = Organisation.find(params[:organisation_id]) }

  def index
    check_access!("admin:organisations:#{@organisation.id}:projects:list")
    @projects = @organisation.projects.all
  end

  def new
    check_access!('admin:projects:create')
    @project = @organisation.projects.new
  end

  def create
    check_access!('admin:projects:create')
    @project = @organisation.projects.create!(project_params)

    flash[:success] = "Created project #{@project.name} \
                       at #{@organisation.name}"

    redirect_to([@organisation, :projects])
  end

  def edit
    check_access!('admin:projects:update')
    @project = @organisation.projects.find(params[:id])
  end

  def update
    check_access!('admin:projects:update')
    @project = @organisation.projects.find(params[:id])
    @project.update_attributes!(project_params)

    flash[:success] = "Updated project #{@project.name} \
                       at #{@organisation.name}"

    redirect_to([@organisation, :projects])
  end

  def show
    check_access!("admin:organisations:#{@organisation.id}:projects:read")
    @project = @organisation.projects.find(params[:id])
  end

  def destroy
    check_access!('admin:projects:delete')
    @project = @organisation.projects.find(params[:id])
    @project.audit_comment = 'Deleted from organisations interface'
    @project.destroy!

    flash[:success] = "Deleted project #{@project.name} \
                       from #{@organisation.name}"

    redirect_to([@organisation, :projects])
  end

  private

  def project_params
    params.require(:project).permit(:name, :aws_account, :state)
  end
end
