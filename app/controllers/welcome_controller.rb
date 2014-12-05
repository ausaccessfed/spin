class WelcomeController < ApplicationController
  before_action do
    @subject = session[:subject_id] && Subject.find(session[:subject_id])
  end

  def index
  end
end
