require 'rails_helper'

RSpec.feature 'After the user has authenticated with idP', type: :feature do
  background do
    attrs = create(:aaf_attributes)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  include_context 'a mocked subject'

  before do
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
  end

  context 'with no projects assigned' do
    include_context 'with no projects'

    scenario 'redirects to no projects page' do
      click_button 'Login'
      expect(current_path).to eq('/dashboard')
      support_md = Rails.root.join('config/support.md').read
      support_html = Kramdown::Document.new(support_md).to_html
      sanitised_support_text = Sanitize.clean(support_html)
      expect(page.body).to have_content(sanitised_support_text)
    end
  end

  context 'with exactly 1 project' do
    include_context 'with 1 project'

    scenario 'redirects to aws auth' do
      click_button 'Login'
      expect(current_path).to eq('/aws_login')
    end
  end

  context 'with more than 1 project' do
    include_context 'with 3 projects'

    scenario 'redirects to projects page' do
      click_button 'Login'
      expect(current_path).to eq('/projects')
    end
  end
end
