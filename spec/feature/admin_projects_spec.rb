require 'rails_helper'

RSpec.feature 'Managing the Projects of an Organisation', type: :feature do
  given(:user) do
    create(:subject, :authorized,
           permission: 'organisations:*')
  end

  given!(:organisation) { create(:organisation) }
  given!(:orig_attrs) { attributes_for(:project).except(:organisation) }
  given!(:project) do
    create(:project,
           orig_attrs.merge(organisation: organisation))
  end

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
    visit '/'
    check 'agree_to_consent'
    click_button 'Log In'
    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    click_link('Organisations', match: :first)
    expect(current_path).to eq('/admin/organisations')
    expect(page).to have_css('table tr td', text: organisation.name)
    click_link 'Projects'
  end

  scenario 'shows active subject' do
    expect(page).to have_text('Logged in as:')
  end

  scenario 'shows the project name in the list' do
    expect(page).to have_css('table tr td', text: project.name)
  end

  scenario 'shows the project provider_arn in the list' do
    expect(page).to have_css('table tr td', text: project.provider_arn)
  end

  scenario 'shows actions for the project' do
    expect(page).to have_content('Project Roles Edit Delete')
  end

  scenario 'shows New Project button' do
    expect(page).to have_content('New Project')
  end

  context 'delete existing' do
    before do
      click_link 'Delete'
    end

    scenario 'does not shows the project name in the list' do
      expect(page).to_not have_css('table tr td', text: project.name)
    end

    scenario 'does not shows the project provider_arn in the list' do
      expect(page).to_not have_css('table tr td', text: project.provider_arn)
    end

    scenario 'does not shows actions for the project' do
      expect(page).to_not have_content('Project Roles Edit Delete')
    end
  end

  context 'edit existing' do
    before do
      click_link 'Edit'
    end

    scenario 'redirects to edit path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/edit")
    end

    scenario 'shows populated name field' do
      expect(page).to have_field('project_name', with: project.name)
    end

    scenario 'shows populated provider_arn field' do
      expect(page).to have_field('project_provider_arn',
                                 with: project.provider_arn)
    end

    scenario 'shows active checkbox' do
      expect(page).to have_field('project_active')
    end

    scenario 'cancels' do
      click_link 'Cancel'
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 'projects')
    end

    context 'saves' do
      given(:name) { Faker::Company.name }

      before do
        fill_in 'project_name', with: name
        uncheck('project_active')
        click_button 'Save'
      end

      scenario 'redirects back to projects' do
        expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                   'projects')
      end

      scenario 'shows flash message' do
        expect(page).to have_content("Updated Project #{name}")
      end

      scenario 'shows the updated project' do
        expect(page).to have_css('table tr td', text: name)
      end

      scenario 'show an inactive status' do
        expect(page).to have_css('table tr td', text: 'No')
      end
    end
  end

  context 'creating new' do
    before do
      click_link 'New Project'
    end

    scenario 'redirects to new path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}" \
                                 '/projects/new')
    end

    scenario 'cancels' do
      click_link 'Cancel'
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 'projects')
    end

    context 'saves' do
      given(:name) { Faker::Company.name }
      given(:provider_arn) do
        "arn:aws:iam::#{Faker::Number.number(3)}:" \
                             "saml-provider/#{Faker::Lorem.characters(10)}"
      end

      context 'with invalid name' do
        before do
          fill_in 'project_provider_arn', with: provider_arn
          click_button 'Create'
        end

        scenario 'shows flash message' do
          expect(page).to have_content('Unable to save Project' \
                                       ' Name can’t be blank')
        end
      end

      context 'with invalid provider_arn' do
        before do
          fill_in 'project_provider_arn', with: 'x'
          fill_in 'project_name', with: Faker::Lorem.word
          click_button 'Create'
        end

        scenario 'shows flash message' do
          expect(page).to have_content('Unable to save Project' \
                                       ' Provider ARN format must be ' \
                                       '‘arn:aws:iam:' \
                                       ':(number):saml-provider/(string)’')
        end
      end

      context 'with valid data and' do
        before do
          fill_in 'project_name', with: name
          fill_in 'project_provider_arn', with: provider_arn
          click_button 'Create'
        end

        scenario 'redirects back to projects' do
          expect(current_path).to eq("/admin/organisations/#{organisation.id}" \
                                     '/projects')
        end

        scenario 'shows flash message' do
          expect(page).to have_content("Created Project #{name}")
        end

        scenario 'shows the created project' do
          expect(page).to have_css('table tr td', text: name)
        end

        scenario 'show an active status' do
          expect(page).to have_css('table tr td', text: 'Yes')
        end
      end
    end
  end
end
