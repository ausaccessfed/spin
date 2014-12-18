class WelcomeController < ApplicationController
  CONSENT_MD = Rails.root.join("config/consent.md").read
  CONSENT_HTML = Kramdown::Document.new(CONSENT_MD).to_html

  def index
    @consent = CONSENT_HTML
  end
end
