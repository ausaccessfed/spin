class RoleArnBelongsToProjectValidator < ActiveModel::EachValidator
  VALIDATION_ERROR = 'role_arn must have the same iam as project.provider_arn'
  def validate_each(object, attribute, value)
    return if object.project.nil?
    first_digit_regex = /\d+/
    object.errors[attribute] << VALIDATION_ERROR unless
        object.project.provider_arn[first_digit_regex, 0] ==
        value[first_digit_regex, 0]
  end
end
