class ProjectsController < ApplicationController
  def index
    public_action
    @projects = @subject.active_project_roles.group_by(&:project)
    Rails.logger.info("User has projects #{@projects} to select from")
  end
end
