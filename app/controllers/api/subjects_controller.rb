module API
  class SubjectsController < APIController
    def show
      check_access!('api:subjects:read')
      @subjects = Subject.all
    end

    def destroy
      check_access!('api:subjects:delete')
      @object = Subject.find(params[:id])
      @object.destroy!
      render status: :ok, nothing: true
    end
  end
end
