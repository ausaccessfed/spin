class ProjectsController < ApplicationController
  before_action :require_subject

  def index
    project_roles = @subject.project_roles.select(:project_id).distinct

    @projects = []
    project_roles.each do |project_role|
      @projects.push(project_role.project)
    end

    Rails.logger.info("User has projects #{@projects} to select from")
  end

  def no_projects_assigned
  end
end
