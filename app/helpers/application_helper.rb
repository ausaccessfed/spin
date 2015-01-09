module ApplicationHelper
  include Lipstick::Helpers::LayoutHelper
  include Lipstick::Helpers::NavHelper
  include Lipstick::Helpers::FormHelper

  SUPPORT_MD = Rails.root.join('config/support.md').read
  SUPPORT_HTML = Kramdown::Document.new(SUPPORT_MD).to_html

  def environment_string
    Rails.application.config.spin_service.environment_string
  end

  def support_html
    SUPPORT_HTML
  end
end
