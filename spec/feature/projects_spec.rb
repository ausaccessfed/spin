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

    before do
      allow(AWSSessionInstance).to receive(:create!).and_return([])
      allow_any_instance_of(AWSSessionInstancesController)
        .to receive(:login_jwt).and_return([])
    end

    scenario 'redirects to aws auth' do
      click_button 'Login'
      expect(current_path).to eq('/idp/profile/SAML2/Unsolicited/SSO')
    end
  end

  context 'with more than 1 project' do
    include_context 'with 3 projects'

    before { click_button 'Login' }

    scenario 'redirects to projects page' do
      expect(current_path).to eq('/projects')
    end

    scenario 'shows the projects' do
      project_roles.map(&:project).map(&:name).each do |project_name|
        expect(page).to have_text(project_name)
      end
    end

    scenario 'shows active subject' do
      expect(page).to have_text('Logged in as:')
    end
  end
end
