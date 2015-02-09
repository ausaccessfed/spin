class WelcomeController < ApplicationController
  skip_before_action :ensure_authenticated
  CONSENT_MD = Rails.root.join('config/consent.md').read
  CONSENT_HTML = Kramdown::Document.new(CONSENT_MD).to_html
  WELCOME_MD = Rails.root.join('config/welcome.md').read
  WELCOME_HTML = Kramdown::Document.new(WELCOME_MD).to_html

  def index
    public_action
    @consent = CONSENT_HTML
    @welcome = WELCOME_HTML
  end
end
