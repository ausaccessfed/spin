json.project_roles @project_roles do |project_role|
  json.id project_role.id
  json.name project_role.name
  json.role_arn project_role.role_arn
end
