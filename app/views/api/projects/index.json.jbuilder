json.projects @projects do |project|
  json.id project.id
  json.name project.name
  json.provider_arn project.provider_arn
  json.active project.active
end
