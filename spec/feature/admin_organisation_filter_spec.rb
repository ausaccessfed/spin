require 'rails_helper'

RSpec.feature 'Filtering Organisations', type: :feature do
  given(:user) do
    create(:subject, :authorized,
           permission: 'organisations:*')
  end

  let!(:organisation) { create(:organisation) }

  background do
    create_list(:organisation, 20)
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    click_link('Organisations', match: :first)
    expect(current_path).to eq('/admin/organisations')
  end

  context 'without a filter' do
    scenario 'shows all entries' do
      expect(page)
        .to have_text('A total of 21 organisations match the current filter.')
    end

    scenario 'shows pagination' do
      expect(page).to have_css('.ui.pagination.menu')
    end
  end

  context 'when supplying filter' do
    before do
      fill_in 'filter', with: filter_string
      click_button 'Update Filter'
    end

    context 'non matching' do
      let(:filter_string) { 'xxxxxx' }

      scenario 'shows 0 match message' do
        expect(page)
          .to have_text('The current filter did not match any Organisations.')
      end

      scenario 'does not show pagination' do
        expect(page).not_to have_css('.ui.pagination.menu')
      end
    end

    context 'organisation name' do
      let(:filter_string) { "#{organisation.name.split(' ').first}*" }

      scenario 'shows 1 match message' do
        expect(page)
          .to have_text('A total of 1 organisations match the current filter.')
      end

      scenario 'does not show pagination' do
        expect(page).not_to have_css('.ui.pagination.menu')
      end
    end

    context 'unique identifier' do
      let(:filter_string) { 'unique_identifier_*' }

      scenario 'shows 21 match message' do
        expect(page)
          .to have_text('A total of 21 organisations match the current filter.')
      end

      scenario 'shows pagination' do
        expect(page).to have_css('.ui.pagination.menu')
      end
    end
  end
end
