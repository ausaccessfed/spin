class RoleArnBelongsToProjectValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    return if obj.project.nil?
    project_prefix = prefix(obj.project.provider_arn)
    role_prefix = prefix(value)

    return if project_prefix == role_prefix
    obj.errors[attribute] << validation_message(project_prefix)
  end

  def validation_message(project_provider_arn_iam)
    "must have the same IAM as the Project's Provider ARN" \
    " (#{project_provider_arn_iam})"
  end

  def prefix(arn)
    match_data = /^(arn:aws:iam::\d+)/.match(arn)
    match_data[0] unless match_data.nil?
  end
end
