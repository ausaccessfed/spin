require 'rails_helper'

RSpec.feature 'After the user has authenticated with idP', type: :feature do
  given(:user) { create(:subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  include_context 'projects'

  before do
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
  end

  context 'with no projects assigned' do
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
    before do
      create_subject_project_role_for_active_project(user)
      allow(AWSSessionInstance).to receive(:create!).and_return([])
      allow_any_instance_of(AWSSessionInstancesController)
        .to receive(:login_jwt).and_return([])
    end

    scenario 'redirects to aws auth' do
      click_button 'Login'
      expect(current_path).to eq('/idp/profile/SAML2/Unsolicited/SSO')
    end
  end

  context 'with more than 1 active projects' do
    given(:subject_project_role_1) do
      create_subject_project_role_for_active_project(user)
    end
    given(:subject_project_role_2) do
      create_subject_project_role_for_active_project(user)
    end

    given!(:project_1) { subject_project_role_1.project_role.project }
    given!(:project_2) { subject_project_role_2.project_role.project }

    before { click_button 'Login' }

    scenario 'redirects to projects page' do
      expect(current_path).to eq('/projects')
    end

    scenario 'shows the projects' do
      expect(page).to have_text(project_1.name)
      expect(page).to have_text(project_2.name)
    end

    scenario 'shows active subject' do
      expect(page).to have_text('Logged in as:')
    end
  end
end
