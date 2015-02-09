class APISubjectRolesController < ApplicationController
  before_action do
    @role = Role.find(params[:role_id])
  end

  def new
    check_access!('admin:roles:grant')
    @api_subjects = APISubject.all
    @assoc = @role.api_subject_roles.new
  end

  def create
    check_access!('admin:roles:grant')
    @assoc = @role.api_subject_roles.build(assoc_params)

    unless @assoc.save
      assign_error_flash
      return redirect_to(new_role_api_member_path(@role))
    end

    flash[:success] = creation_message(@assoc)
    redirect_to(role_path(@role))
  end

  def destroy
    check_access!('admin:roles:revoke')
    @assoc = @role.api_subject_roles.find(params[:id])
    @assoc.destroy!

    flash[:success] = deletion_message(@assoc)

    redirect_to(role_path(@role))
  end

  private

  def assoc_params
    params.require(:api_subject_roles).permit(:api_subject_id)
  end

  def creation_message(assoc)
    "Granted #{@role.name} to API Account: " \
      "#{assoc.api_subject.x509_cn}"
  end

  def deletion_message(assoc)
    "Revoked #{@role.name} from API Account: " \
      "#{assoc.api_subject.x509_cn}"
  end

  def assign_error_flash
    flash[:error] = "#{error_from_validations(@assoc)}"
  end
end
