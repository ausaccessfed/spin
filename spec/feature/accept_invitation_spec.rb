require 'rails_helper'

RSpec.feature 'Visiting the invitation page', type: :feature do
  given(:invitation) { create(:invitation) }
  given!(:subject_project_role) do
    create(:subject_project_role, subject: invitation.subject)
  end

  background do
    attrs = create(:aaf_attributes, displayname: invitation.name,
                                    mail: invitation.mail)

    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  context 'with an unexpired, unused invitation' do
    scenario 'accepting the invitation' do
      visit "/invitations/#{invitation.identifier}"
      click_button 'Accept'

      expect(current_path).to eq('/auth/login')
      click_button 'Login'

      expect(current_path).to eq('/invitation_complete')
      expect(page).to have_content('Your account has access to the AWS ' \
       "project, #{invitation.project_name}. Continue to the AWS" \
       ' administrative console for this project.')
    end

    context 'with no projects' do
      given!(:subject_project_role) {}

      scenario 'attempting to accept the invitation' do
        visit "/invitations/#{invitation.identifier}"
        expect(page).to have_content('You have been invited to login to be a'\
          ' part of future projects')
        expect(page).to have_content('After clicking the Accept Invitation'\
          ' button below you will be asked to log in via the Australian Access'\
          ' Federation to prove your identity.')
      end
    end

    context 'with no active projects' do
      given(:project) { create(:project, active: false) }
      given(:project_role) { create(:project_role, project: project) }
      given!(:subject_project_role) do
        create(:subject_project_role, project_role: project_role)
      end
      given(:invitation) do
        create(:invitation, subject: subject_project_role.subject)
      end

      scenario 'attempting to accept the invitation' do
        visit "/invitations/#{invitation.identifier}"
        expect(page).to have_content('You have been invited to login to be a'\
          ' part of future projects')
        expect(page).to have_content('After clicking the Accept Invitation'\
          ' button below you will be asked to log in via the Australian Access'\
          ' Federation to prove your identity.')
      end
    end
  end

  context 'with a used invitation' do
    given(:invitation) { create(:invitation, used: true) }

    scenario 'attempting to accept the invitation' do
      visit "/invitations/#{invitation.identifier}"
      expect(page).to have_content('already been accepted')
      expect(page).to have_link('View Dashboard')
    end
  end

  context 'with an expired invitation' do
    given(:invitation) { create(:invitation, expires: 1.day.ago) }

    scenario 'attempting to accept the invitation' do
      visit "/invitations/#{invitation.identifier}"
      expect(page).to have_content('invitation expired')
    end

    context 'with no projects' do
      given!(:subject_project_role) {}

      scenario 'attempting to accept the invitation' do
        visit "/invitations/#{invitation.identifier}"
        expect(page).to have_content('invitation expired')
      end
    end

    context 'with no active projects' do
      given(:project) { create(:project, active: false) }
      given(:project_role) { create(:project_role, project: project) }
      given!(:subject_project_role) do
        create(:subject_project_role, project_role: project_role)
      end
      given(:invitation) do
        create(:invitation, expires: 1.day.ago, subject:
                              subject_project_role.subject)
      end

      scenario 'attempting to accept the invitation' do
        visit "/invitations/#{invitation.identifier}"
        expect(page).to have_content('invitation expired')
      end
    end
  end
end
