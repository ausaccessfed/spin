class SubjectProjectRolesController < ApplicationController
  before_action do
    @organisation = Organisation.find(params[:organisation_id])
    @project = Project.find(params[:project_id])
    @project_role = ProjectRole.find(params[:role_id])
  end

  def new
    check_access!("#{access_prefix}:grant")

    subjects_scope = Subject.all

    if params[:filter].present?
      subjects_scope = subjects_scope.filter(params[:filter])
    end

    @filter = params[:filter]
    @subjects =
      smart_listing_create(:subject_project_role, subjects_scope,
                           partial: 'subject_project_roles/listing',
                           default_sort: { name: 'asc' })

    @assoc = @project_role.subject_project_roles.new
  end

  def create
    check_access!("#{access_prefix}:grant")
    @assoc = @project_role.subject_project_roles.build(assoc_params)
    unless @assoc.save
      assign_error_flash
      return redirect_to(organisation_project_role_path(@organisation, @project,
                                                        @project_role))
    end
    assign_creation_message
    redirect_to(organisation_project_role_path(@organisation, @project,
                                               @project_role))
  end

  def destroy
    check_access!("#{access_prefix}:revoke")
    subject = Subject.find(params[:id])
    @project_role.subjects.delete(subject)

    flash[:success] = deletion_message(subject)

    redirect_to(organisation_project_role_path(@organisation, @project,
                                               @project_role))
  end

  private

  def assoc_params
    params.require(:subject_project_roles).permit(:subject_id)
  end

  def assign_creation_message
    flash[:success] = creation_message(@assoc)
  end

  def assign_error_flash
    flash[:error] = "#{error_from_validations(@assoc)}"
  end

  def creation_message(assoc)
    "Granted #{@project_role.name} to #{assoc.subject.name}"
  end

  def deletion_message(subject)
    "Revoked #{@project_role.name} from #{subject.name}"
  end

  def access_prefix
    "organisations:#{@organisation.id}:projects:#{@project.id}:roles"
  end
end
