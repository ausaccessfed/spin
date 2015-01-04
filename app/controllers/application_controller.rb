class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def subject
    @subject = session[:subject_id] && Subject.find(session[:subject_id])
  end

  def require_subject
    subject || redirect_to(root_path)
  end
end
