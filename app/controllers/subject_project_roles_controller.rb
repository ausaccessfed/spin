class SubjectProjectRolesController < ApplicationController
  before_action do
    @organisation = Organisation.find(params[:organisation_id])
    @project = Project.find(params[:project_id])
    @project_role = ProjectRole.find(params[:role_id])
  end

  def new
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:grant")
    @subjects = Subject.all
    @assoc = @project_role.subject_project_roles.new
  end

  def create
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:grant")

    @assoc = @project_role.subject_project_roles.build(assoc_params)
    unless @assoc.save
      assign_error_flash
      return redirect_to(new_organisation_project_role_path(@project_role))
    end

    assign_creation_message
    redirect_to(organisation_project_role_path(@organisation, @project,
                                               @project_role))
  end

  def assign_creation_message
    flash[:success] = creation_message(@assoc)
  end

  def assign_error_flash
    flash[:error] = "#{error_from_validations(@assoc)}"
  end

  def destroy
    check_access!("organisations:#{@organisation.id}:" \
                  "projects:#{@project.id}:roles:revoke")
    @assoc = @project_role.subject_project_roles.find(params[:id])
    @assoc.destroy!

    flash[:success] = deletion_message(@assoc)

    redirect_to(organisation_project_role_path(@organisation, @project,
                                               @project_role))
  end

  private

  def assoc_params
    params.require(:subject_project_roles).permit(:subject_id)
  end

  def creation_message(assoc)
    "Granted #{@project_role.name} to #{assoc.subject.name}"
  end

  def deletion_message(assoc)
    "Revoked #{@project_role.name} from #{assoc.subject.name}"
  end
end
