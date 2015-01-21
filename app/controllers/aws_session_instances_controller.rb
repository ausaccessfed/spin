class AWSSessionInstancesController < ApplicationController
  before_action { @project_role = ProjectRole.find(params[:project_role_id]) }

  def create
    # A ProjectRole doesn't imply any permissions, so we only need to check the
    # subject's membership in the role.
    public_action
    fail(Forbidden) unless subject.project_roles.include?(@project_role)

    @instance = AWSSessionInstance.create!(subject: subject,
                                           project_role: @project_role)
    redirect_to sso_url(@instance)
  end

  private

  def sso_url(instance)
    '/idp/profile/SAML2/Unsolicited/SSO?providerId=urn:amazon:webservices&' \
      "spin_session_instance=#{instance.identifier}"
  end
end
