require 'rails_helper'

RSpec.feature 'Managing the AWS Roles of an Project', type: :feature do
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
  let!(:project_role) { create(:project_role, project_id: project.id) }

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
    click_link 'Projects (1)'
    expect(page).to have_css('table tr td', text: project.name)
    click_link 'Project Roles (1)'
  end

  scenario 'shows the project_role name in the list' do
    expect(page).to have_css('table tr td', text: project_role.name)
  end

  scenario 'shows actions for the project_role' do
    expect(page).to have_content('Members (0) Edit Delete')
  end

  scenario 'shows New Project Role button' do
    expect(page).to have_content('New Project Role')
  end

  context 'creating new' do
    before do
      click_link 'New Project Role'
    end

    scenario 'redirects to new path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 'roles/new')
    end

    scenario 'cancels' do
      click_link 'Cancel'
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 'roles')
    end

    context 'saves' do
      given(:bs) { Faker::Company.bs }
      given(:role_arn) { Faker::Lorem.characters(10) }

      context 'with invalid data' do
        before do
          click_button 'Create'
        end

        scenario 'shows flash message' do
          expect(page).to have_content('Unable to create Project Role' \
                                       " Name can't be blank")
        end
      end

      context 'with valid data' do
        before do
          fill_in 'project_role_name', with: bs
          fill_in 'project_role_role_arn', with: role_arn
          click_button 'Create'
        end

        scenario 'redirects back to project_roles' do
          expect(current_path).to eq("/admin/organisations/#{organisation.id}" \
                                         "/projects/#{project.id}" \
                                         '/roles')
        end

        scenario 'shows flash message' do
          expect(page).to have_content("Created Project Role #{bs}")
        end

        scenario 'shows the created project_role' do
          expect(page).to have_css('table tr td', text: bs)
        end
      end
    end
  end

  context 'delete existing' do
    before do
      click_link 'Delete'
    end

    scenario 'does not shows the project_role name in the list' do
      expect(page).to_not have_css('table tr td', text: project_role.name)
    end

    scenario 'does not shows the project_role name in the list' do
      expect(page).to_not have_css('table tr td', text: project_role.name)
    end

    scenario 'does not shows actions for the project_role' do
      expect(page).to_not have_content('Members (0) Edit Delete')
    end
  end

  context 'edit existing' do
    before do
      click_link 'Edit'
    end

    scenario 'redirects to edit path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}/edit")
    end

    scenario 'shows populated name field' do
      expect(page).to have_field('project_role_name', with: project_role.name)
    end

    scenario 'shows populated name field' do
      expect(page).to have_field('project_role_name',
                                 with: project_role.name)
    end

    scenario 'cancels' do
      click_link 'Cancel'
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/roles")
    end

    context 'saves' do
      given(:more_bs) { Faker::Company.bs }

      before do
        fill_in 'project_role_name', with: more_bs
        click_button 'Save'
      end

      scenario 'redirects back to project_roles' do
        expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                    "projects/#{project.id}/" \
                                    'roles')
      end

      scenario 'shows flash message' do
        expect(page).to have_content("Updated Project Role #{more_bs}")
      end

      scenario 'shows the updated project_role' do
        expect(page).to have_css('table tr td', text: more_bs)
      end
    end
  end
end
