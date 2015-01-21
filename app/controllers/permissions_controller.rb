class PermissionsController < ApplicationController
  before_action do
    @role = Role.find(params[:role_id])
  end

  def index
    check_access!('admin:roles:read')
    @permissions = @role.permissions.all
    @new_permission = @role.permissions.build
  end

  def create
    check_access!('admin:roles:update')
    permission = @role.permissions.build(permission_params)

    unless permission.save
      assign_error_flash(permission)
      return redirect_to(role_permissions_path(@role))
    end

    flash[:success] = "Added permission: #{permission.value}"
    redirect_to(role_permissions_path(@role))
  end

  def destroy
    check_access!('admin:roles:update')

    @permission = @role.permissions.find(params[:id])
    @permission.destroy!

    flash[:success] = "Removed permission: #{@permission.value}"
    redirect_to(role_permissions_path(@role))
  end

  private

  def permission_params
    params.require(:permission).permit(:value)
  end

  def assign_error_flash(permission)
    flash[:error] = "#{error_from_validations(permission)}"
  end
end
