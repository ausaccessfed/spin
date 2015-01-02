module ApplicationHelper
  include Lipstick::Helpers::LayoutHelper
  include Lipstick::Helpers::NavHelper
  include Lipstick::Helpers::FormHelper

  def environment_string
    Rails.application.config.spin_service.environment_string
  end
end
