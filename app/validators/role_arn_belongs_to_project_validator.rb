class RoleArnBelongsToProjectValidator < ActiveModel::EachValidator
  def validate_each(obj, attribute, value)
    return if obj.project.nil?
    first_digit_regex = /\d+/
    project_provider_arn_iam = project_provider_arn_iam(first_digit_regex, obj)
    role_arn_iam = value[first_digit_regex, 0]
    obj.errors[attribute] << validation_message(project_provider_arn_iam) unless
        project_provider_arn_iam == role_arn_iam
  end

  def validation_message(project_provider_arn_iam)
    "must have the same IAM as the Project's Provider ARN" \
    " (#{project_provider_arn_iam})"
  end

  def project_provider_arn_iam(first_digit_regex, object)
    object.project.provider_arn[first_digit_regex, 0]
  end
end
