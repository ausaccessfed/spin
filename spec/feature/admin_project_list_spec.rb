require 'rails_helper'

RSpec.feature 'Listing all Projects', type: :feature do
  given(:user) { create(:subject, :authorized, permission: '*') }
  given(:organisation) { create(:organisation) }
  given!(:project) { create(:project, organisation: organisation) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    click_link('AWS Projects', match: :first)
    expect(current_path).to eq('/admin/projects')
  end

  scenario 'shows the project name' do
    expect(page).to have_content(project.name)
  end

  scenario 'shows the provider arn' do
    expect(page).to have_content(project.provider_arn)
  end

  scenario 'shows the associated organisation name' do
    expect(page).to have_content(organisation.name)
  end

  scenario 'shows the project status' do
    expect(page).to have_content('Yes')
  end

  scenario 'shows the Project Role link for the project' do
    expect(page).to have_link('Project Roles')
  end

  scenario 'shows the Edit link for the project' do
    expect(page).to have_link('Edit')
  end

  scenario 'shows the Delete link for the project' do
    expect(page).to have_link('Delete')
  end
end
