class DashboardController < ApplicationController
  def index
    public_action
    @organisation_count = Organisation.count
    @project_count = Project.count
    @subject_count = Subject.count
  end
end
