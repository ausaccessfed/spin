module API
  class SubjectsController < APIController
    def index
      check_access!('api:subjects:list')
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
