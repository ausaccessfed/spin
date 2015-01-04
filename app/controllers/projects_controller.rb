class ProjectsController < ApplicationController
  SUPPORT_MD = Rails.root.join('config/support.md').read
  SUPPORT_HTML = Kramdown::Document.new(SUPPORT_MD).to_html

  before_action :require_subject

  def index
    @projects = @subject.projects
    Rails.logger.info("User has projects #{@projects} to select from")
  end

  def no_projects_assigned
    @support = SUPPORT_HTML
  end
end
