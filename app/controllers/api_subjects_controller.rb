class APISubjectsController < ApplicationController
  def index
    check_access!('admin:api_subjects:list')
    @api_subjects = APISubject.all
  end

  def new
    check_access!('admin:api_subjects:create')
    @api_subject = APISubject.new
  end

  def create
    check_access!('admin:api_subjects:create')
    @api_subject = APISubject.new(api_subject_params)

    unless @api_subject.save
      Rails.logger.info("create api_subject {#{ @api_subject }} not valid")
      return form_error('new', 'Unable to create API Account', @api_subject)
    end

    flash[:success] = "Created new API Account: #{@api_subject.description}"
    redirect_to(:api_subjects)
  end

  def edit
    check_access!('admin:api_subjects:update')
    @api_subject = APISubject.find(params[:id])
  end

  def update
    check_access!('admin:api_subjects:update')
    @api_subject = APISubject.find(params[:id])

    unless @api_subject.update_attributes(api_subject_params)
      return form_error('edit', 'Unable to save API Account', @api_subject)
    end

    flash[:success] = "Updated API Account: #{@api_subject.description}"
    redirect_to(:api_subjects)
  end

  def show
    check_access!('admin:api_subjects:read')
    @api_subject = APISubject.find(params[:id])
  end

  def destroy
    check_access!('admin:api_subjects:delete')
    @api_subject = APISubject.find(params[:id])
    @api_subject.destroy!
    flash[:success] = "Deleted API Account: #{@api_subject.x509_cn}"
    redirect_to(api_subjects_path)
  end

  private

  def api_subject_params
    params.require(:api_subject)
      .permit(:x509_cn, :name, :description, :contact_name, :contact_mail)
  end
end
