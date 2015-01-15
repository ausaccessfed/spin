require 'rails_helper'

RSpec.feature 'API Subjects Admin', type: :feature do
  given(:user) { create(:subject, :authorized, complete: true) }
  given!(:api_subject) { create(:api_subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    click_link('API Accounts')
    expect(current_path).to eq('/admin/api_subjects')
  end

  scenario 'viewing the api subject list' do
    expect(page).to have_css('tr td', text: api_subject.x509_cn)
  end

  scenario 'editing a api subject' do
    within('tr', text: api_subject.x509_cn) do
      click_link('Edit')
    end

    expect(current_path)
      .to eq("/admin/api_subjects/#{api_subject.id}/edit")

    old_cn = api_subject.x509_cn
    attrs = attributes_for(:api_subject)

    within('form') do
      fill_in 'Description', with: attrs[:description]
      fill_in 'X.509 CN', with: attrs[:x509_cn]
      fill_in 'Contact Name', with: attrs[:contact_name]
      fill_in 'Contact Email Address', with: attrs[:contact_mail]
      click_button('Save')
    end

    expect(page).to have_css('tr td', text: attrs[:x509_cn])
    expect(page).to have_no_css('tr td', text: old_cn)
  end

  scenario 'creating a api subject' do
    click_link('New API Account')

    expect(current_path).to eq('/admin/api_subjects/new')

    attrs = attributes_for(:api_subject)

    within('form') do
      fill_in 'Description', with: attrs[:description]
      fill_in 'X.509 CN', with: attrs[:x509_cn]
      fill_in 'Contact Name', with: attrs[:contact_name]
      fill_in 'Contact Email Address', with: attrs[:contact_mail]
      click_button('Create')
    end

    expect(current_path).to eq('/admin/api_subjects')
    expect(page).to have_css('tr td', text: attrs[:x509_cn])
  end

  scenario 'deleting a api subject' do
    within('tr', text: api_subject.x509_cn) do
      click_delete_button
    end

    expect(current_path).to eq('/admin/api_subjects')
    expect(page).to have_no_css('tr td', text: api_subject.x509_cn)
  end
end
