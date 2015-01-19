class ProjectsController < ApplicationController
  def index
    public_action
    @projects = @subject.projects
    Rails.logger.info("User has projects #{@projects} to select from")
  end
end
