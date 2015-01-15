module RolesHelper
  def member_count(role)
    role.subject_roles.count + role.api_subject_roles.count
  end
end
