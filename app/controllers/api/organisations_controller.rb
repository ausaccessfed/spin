module API
  class OrganisationsController < APIController
    def create
      check_access!('api:organisations:create')
      @organisation = Organisation.create!(organisation_params)
      render status: :created, nothing: true
    end

    def update
      check_access!('api:organisations:update')
      organisation_id = params[:id]
      @organisation = Organisation.find(organisation_id)
      @organisation.update_attributes!(organisation_params)
      render status: :ok, nothing: true
    end

    def index
      check_access!('api:organisations:list')
      @organisations = Organisation.all
    end

    def destroy
      check_access!('api:organisations:delete')
      organisation_id = params[:id]
      @organisation = Organisation.find(organisation_id)
      @organisation.destroy!
      render status: :ok, nothing: true
    end

    private

    def organisation_params
      params.require(:organisation).permit(:name, :external_id)
    end
  end
end
