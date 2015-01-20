require 'rails_helper'

RSpec.feature 'Managing the members of an AWS Role', type: :feature do
  given!(:user) do
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
  let!(:subject_project_role) do
    create(:subject_project_role,
           project_role_id: project_role.id,
           subject_id: user.id)
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
    click_link 'Projects (1)'
    expect(page).to have_css('table tr td', text: project.name)
    click_link 'Project Roles (1)'
    expect(page).to have_css('table tr td', text: project_role.name)
    click_link 'Members (1)'
  end

  scenario 'has view role path' do
    expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}")
  end

  scenario 'shows the subject name in the list' do
    expect(page).to have_css('table tr td', text: user.name)
  end

  scenario 'shows actions for the subject' do
    expect(page).to have_content("#{user.name} Revoke")
  end

  scenario 'shows Add Subject button' do
    expect(page).to have_content('Add Subject')
  end

  context 'revokes subject' do
    before { click_delete_button(text: 'Revoke') }

    scenario 'shows flash' do
      expect(page).to have_content("Revoked #{project_role.name} " \
                                   "from #{user.name}")
    end

    scenario 'has view role path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}")
    end

    scenario 'does not show the subject name in the list' do
      expect(page).to_not have_css('table tr td', text: user.name)
    end

    scenario 'does not show actions for the subject' do
      expect(page).to_not have_content("#{user.name} Revoke")
    end
  end

  context 'add subject' do
    given!(:another_user) do
      create(:subject, :authorized,
             permission: 'organisations:*')
    end

    before { click_link('Add Subject') }

    scenario 'shows the subject name in the list' do
      expect(page).to have_css('table tr td', text: another_user.name)
    end

    scenario 'shows actions for the subject' do
      expect(page).to have_content("#{another_user.mail} Grant")
    end

    scenario 'shows that original subject is already granted' do
      expect(page).to have_content("#{user.mail} Granted")
    end

    scenario 'has grant role path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}/members/new")
    end

    context 'grants role' do
      before { click_button('Grant') }

      scenario 'has view role path' do
        expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}")
      end

      scenario 'shows flash' do
        expect(page).to have_content("Granted #{project_role.name} " \
                                   "to #{another_user.name}")
      end

      scenario 'shows the subject name in the list' do
        expect(page).to have_css('table tr td', text: another_user.name)
      end

      scenario 'shows that subject is granted' do
        expect(page).to have_content("#{another_user.name} Revoke")
      end
    end
  end
end
