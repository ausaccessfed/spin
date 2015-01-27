module API
  class SubjectsController < APIController
    def show
      check_access!('api:subjects:read')
      @subjects = Subject.all
    end
  end
end
