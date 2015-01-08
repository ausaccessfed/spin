class ProjectsController < ApplicationController
  SUPPORT_MD = Rails.root.join('config/support.md').read
  SUPPORT_HTML = Kramdown::Document.new(SUPPORT_MD).to_html

  def index
    public_action
    @projects = @subject.projects
    Rails.logger.info("User has projects #{@projects} to select from")
  end

  def no_projects_assigned
    public_action
    @support = SUPPORT_HTML
  end
end
