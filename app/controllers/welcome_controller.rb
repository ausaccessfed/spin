class WelcomeController < ApplicationController
  skip_before_action :ensure_authenticated
  CONSENT_MD = Rails.root.join('config/consent.md').read
  CONSENT_HTML = Kramdown::Document.new(CONSENT_MD).to_html

  def index
    public_action
    @consent = CONSENT_HTML
  end
end
