class SubjectRolesController < ApplicationController
  before_action do
    @role = Role.find(params[:role_id])
  end

  def new
    check_access!('admin:roles:grant')
    @subjects = Subject.all
    @assoc = @role.subject_roles.new
  end

  def create
    check_access!('admin:roles:grant')
    @assoc = @role.subject_roles.build(assoc_params)

    unless @assoc.save
      assign_error_flash
      return redirect_to(new_role_member_path(@role))
    end

    flash[:success] = creation_message(@assoc)

    redirect_to(role_path(@role))
  end

  def destroy
    check_access!('admin:roles:revoke')
    @assoc = @role.subject_roles.find(params[:id])
    @assoc.destroy!

    flash[:success] = deletion_message(@assoc)

    redirect_to(role_path(@role))
  end

  private

  def assoc_params
    params.require(:subject_roles).permit(:subject_id)
  end

  def creation_message(assoc)
    "Granted #{@role.name} to #{assoc.subject.name}"
  end

  def deletion_message(assoc)
    "Revoked #{@role.name} from #{assoc.subject.name}"
  end

  def assign_error_flash
    flash[:error] = "#{error_from_validations(@assoc)}"
  end
end
