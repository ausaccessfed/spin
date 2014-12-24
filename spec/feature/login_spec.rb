require 'rails_helper'

RSpec.feature 'Visiting the welcome page', type: :feature do
  background do
    attrs = create(:aaf_attributes)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  scenario 'displays consent and log in button' do
    visit '/'

    expect(page).to have_text('Welcome to SPIN')
    expect(page).to have_link('Welcome')

    consent_md = Rails.root.join('config/consent.md').read
    consent_html = Kramdown::Document.new(consent_md).to_html
    sanitised_consent = Sanitize.clean(consent_html)

    expect(page.body).to have_content(sanitised_consent)
    expect(page).to have_field('agree_to_consent')
    expect(page).to have_button('Log In')
  end

  scenario 'disallows log in when consent is not agreed', js: true do
    visit '/'
    click_button 'Log In'
    expect(current_path).to eq('/')
    expect(page).to have_content('You must agree to the terms and conditions')
  end

  scenario 'allows log in when consent is agreed' do
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
  end

  scenario 'disallows access without being logged in' do
    visit '/projects'
    expect(current_path).to eq('/')
  end
end
