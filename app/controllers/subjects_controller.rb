class SubjectsController < ApplicationController
  def index
    check_access!('admin:subjects:list')
    @objects = Subject.all
  end

  def show
    check_access!('admin:subjects:read')
    @object = Subject.find(params[:id])
  end

  def destroy
    check_access!('admin:subjects:delete')
    @object = Subject.find(params[:id])
    @object.destroy!

    flash[:success] = "Deleted subject #{@object.name}"

    redirect_to(subjects_path)
  end
end
