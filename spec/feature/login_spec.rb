require 'rails_helper'

RSpec.feature 'Visiting the welcome page', type: :feature do
  background do
    attrs = create(:aaf_attributes)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  def md_to_sanitised_text(file)
    md = Rails.root.join(file).read
    sanitised_text = Kramdown::Document.new(md).to_html
    Sanitize.clean(sanitised_text)
  end

  context 'visiting /' do
    before { visit '/' }

    scenario 'displays welcome text' do
      expect(page).to have_text('Welcome to SPIN')
      expect(page).to have_link('Welcome')
    end

    scenario 'displays consent' do
      sanitised_consent = md_to_sanitised_text('config/consent.md')
      expect(page.body).to have_content(sanitised_consent)
    end

    scenario 'displays welcome text' do
      sanitised_welcome_text = md_to_sanitised_text('config/welcome.md')
      expect(page.body).to have_content(sanitised_welcome_text)
    end

    scenario 'displays log in fields' do
      expect(page).to have_field('agree_to_consent')
      expect(page).to have_button('Log In')
    end

    scenario 'has no active subject' do
      expect(page).not_to have_text('Logged in as:')
    end

    scenario 'disallows log in when consent is not agreed', js: true do
      click_button 'Log In'
      expect(current_path).to eq('/')
      expect(page).to have_content('You must agree to the terms and conditions')
    end

    scenario 'allows log in when consent is agreed' do
      check 'agree_to_consent'
      click_button 'Log In'
      expect(current_path).to eq('/auth/login')
    end

    scenario 'displays the environment text' do
      spin_cfg_hash = YAML.load_file(Rails.root.join('config/spin_service.yml'))
      spin_cfg_os = OpenStruct.new(spin_cfg_hash)
      expect(page).to have_text(spin_cfg_os.environment_string)
    end
  end

  scenario 'disallows access without being logged in' do
    visit '/projects'
    expect(current_path).to eq('/auth/login')
  end
end
