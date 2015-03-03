RSpec.shared_context 'projects' do
  def create_subject_project_role(subject, active)
    project = create(:project, active: active)
    project_role = create(:project_role, project: project)
    create(:subject_project_role, project_role: project_role,
                                  subject: subject)
  end

  def create_subject_project_role_for_active_project(subject)
    create_subject_project_role(subject, true)
  end

  def create_subject_project_role_for_inactive_project(subject)
    create_subject_project_role(subject, false)
  end
end
