RSpec.shared_context 'projects' do
  def create_project(subject, active)
    project = create(:project, active: active)
    project_role = create(:project_role, project: project)
    create(:subject_project_role, project_role: project_role,
                                  subject: subject)
  end

  def create_active_project(subject)
    create_project(subject, true)
  end

  def create_inactive_project(subject)
    create_project(subject, false)
  end
end
