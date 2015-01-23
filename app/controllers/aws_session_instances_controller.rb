class AWSSessionInstancesController < ApplicationController
  def auto
    project_role = subject.project_roles.first

    # Access is implied because we're automatically signing in to the subject's
    # only project role.
    public_action
    fail(Forbidden) if project_role.nil?

    perform_login(subject, project_role)
  end

  def login
    project_role = ProjectRole.find(params[:project_role_id])

    # A ProjectRole doesn't imply any permissions, so we only need to check the
    # subject's membership in the role.
    public_action
    fail(Forbidden) unless subject.project_roles.include?(project_role)

    perform_login(subject, project_role)
  end

  private

  def sso_url
    '/idp/profile/SAML2/Unsolicited/SSO?providerId=urn:amazon:webservices'
  end

  def perform_login(subject, project_role)
    instance = AWSSessionInstance.create!(subject: subject,
                                          project_role: project_role)

    cookies['spin_login'] = login_jwt(instance)
    redirect_to sso_url
  end

  def login_jwt(instance)
    jwt = JSON::JWT.new(sub: instance.identifier, exp: 2.minutes.from_now)
    secret = Rails.application.config.spin_service.login_jwt_secret

    jwt.sign(secret).to_s
  end
end
