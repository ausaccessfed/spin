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

  def sso_url(instance)
    '/idp/profile/SAML2/Unsolicited/SSO?providerId=urn:amazon:webservices&' \
      "spin_session_instance=#{instance.identifier}"
  end

  def perform_login(subject, project_role)
    instance = AWSSessionInstance.create!(subject: subject,
                                          project_role: project_role)
    redirect_to sso_url(instance)
  end
end
