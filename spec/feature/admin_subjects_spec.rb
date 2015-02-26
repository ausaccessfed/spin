require 'rails_helper'

RSpec.feature 'Managing the Subjects', type: :feature do
  given(:user) { create(:subject, :authorized, complete: true) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    click_link('Users', match: :first)
    expect(current_path).to eq('/admin/subjects')
  end

  scenario 'shows the subject list' do
    expect(page).to have_css('table tr td', text: user.name)
  end

  scenario 'shows actions' do
    expect(page).to have_content('View Delete')
  end

  scenario 'shows active subject' do
    expect(page).to have_text('Logged in as:')
  end

  scenario 'viewing a subject record' do
    within('table tr', text: user.name) do
      click_link('View')
    end

    expect(current_path).to eq("/admin/subjects/#{user.id}")
    expect(page).to have_content(user.name)
    expect(page).to have_content(user.mail)
    expect(page).to have_content(user.shared_token)
    expect(page).to have_content(user.targeted_id)
  end

  scenario 'deleting a subject record' do
    within('table tr', text: user.name) do
      click_delete_button
    end

    expect(current_path).to eq('/admin/subjects')
    expect(page).to have_no_content(user.mail)
  end
end
