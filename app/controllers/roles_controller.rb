class RolesController < ApplicationController
  def index
    check_access!('admin:roles:list')
    @roles = Role.all
  end

  def new
    check_access!('admin:roles:create')
    @role = Role.new
  end

  def create
    check_access!('admin:roles:create')
    @role = Role.new(role_params)

    unless @role.save
      Rails.logger.info("create role {#{ @role }} not valid")
      return form_error('new', 'Unable to create Role', @role)
    end

    flash[:success] = "Created new Role: #{@role.name}"
    redirect_to(:roles)
  end

  def edit
    check_access!('admin:roles:update')
    @role = Role.find(params[:id])
  end

  def update
    check_access!('admin:roles:update')
    @role = Role.find(params[:id])

    unless @role.update_attributes(role_params)
      return form_error('edit', 'Unable to save Role', @role)
    end

    flash[:success] = "Updated Role: #{@role.name}"
    redirect_to(:roles)
  end

  def show
    check_access!('admin:roles:read')
    @role = Role.find(params[:id])
  end

  def destroy
    check_access!('admin:roles:delete')
    @role = Role.find(params[:id])
    @role.destroy!
    flash[:success] = "Deleted Role: #{@role.name}"
    redirect_to(roles_path)
  end

  private

  def role_params
    params.require(:role)
      .permit(:name)
  end
end
