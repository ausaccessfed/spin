module API
  class OrganisationsController < APIController
    def create
      check_access!('api:organisations:create')
      @organisation = Organisation.create!(organisation_params)
      render status: :ok, nothing: true
    end

    def update
      check_access!('api:organisations:update')
      @organisation = Organisation.find(params[:id])
      @organisation.update_attributes!(organisation_params)
      render status: :ok, nothing: true
    end

    def show
      check_access!('api:organisations:read')
      @organisations = Organisation.all
    end

    def destroy
      check_access!('api:organisations:delete')
      @organisation = Organisation.find(params[:id])
      @organisation.destroy!
      render status: :ok, nothing: true
    end

    private

    def organisation_params
      params.require(:organisation).permit(:name, :external_id)
    end
  end
end
