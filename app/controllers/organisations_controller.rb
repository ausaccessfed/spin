class OrganisationsController < ApplicationController
  def index
    check_access!('organisations:list')
    @organisations = Organisation.all
  end

  def new
    check_access!('organisations:create')
    @organisation = Organisation.new
  end

  def create
    check_access!('organisations:create')
    @organisation = Organisation.new(organisation_params)

    unless @organisation.save
      Rails.logger.info("create organisation {#{ @organisation }} not valid")
      return form_error('new', 'Unable to create Organisation', @organisation)
    end

    flash[:success] = "Created new Organisation: #{@organisation.name}"
    redirect_to(:organisations)
  end

  def edit
    check_access!('organisations:update')
    @organisation = Organisation.find(params[:id])
  end

  def update
    check_access!('organisations:update')
    @organisation = Organisation.find(params[:id])

    unless @organisation.update_attributes(organisation_params)
      return form_error('edit', 'Unable to save Organisation', @organisation)
    end

    flash[:success] = "Updated Organisation: #{@organisation.name}"
    redirect_to(:organisations)
  end

  def destroy
    check_access!('organisations:delete')
    @organisation = Organisation.find(params[:id])
    @organisation.destroy!
    flash[:success] = "Deleted Organisation: #{@organisation.name}"
    redirect_to(organisations_path)
  end

  private

  def organisation_params
    params.require(:organisation)
      .permit(:name, :external_id)
  end
end
