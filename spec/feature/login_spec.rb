require 'rails_helper'

RSpec.feature 'Visiting the welcome page', type: :feature do
  scenario 'displays consent and log in button' do
    visit '/'

    expect(page).to have_text('Welcome to SPIN')

    consent_md = Rails.root.join('config/consent.md').read
    consent_html = Kramdown::Document.new(consent_md).to_html
    sanitised_consent = Sanitize.clean(consent_html)

    expect(page.body).to have_content(sanitised_consent)
    expect(page).to have_field('agree_to_consent')
    expect(page).to have_link('Log In')
  end

  scenario 'disallows log in when consent is not agreed' do
    visit '/'
    click 'Log In'
  end

  scenario 'disallows access without consent' do
    visit '/'
  end
end
