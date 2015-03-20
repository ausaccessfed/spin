module ApplicationHelper
  include Lipstick::Helpers::LayoutHelper
  include Lipstick::Helpers::NavHelper
  include Lipstick::Helpers::FormHelper

  VERSION = '1.0.0-beta.2'

  SUPPORT_MD = Rails.root.join('config/support.md').read
  SUPPORT_HTML = Kramdown::Document.new(SUPPORT_MD).to_html

  def support_html
    SUPPORT_HTML
  end

  def markdown_to_html(input)
    Kramdown::Document.new(input).to_html.html_safe
  end
end
