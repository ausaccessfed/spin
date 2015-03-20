require 'rails_helper'

RSpec.feature 'Managing the members of an AWS Role', type: :feature do
  given!(:user) { create(:subject, :authorized, permission: 'organisations:*') }
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
    click_link 'Projects'
    expect(page).to have_css('table tr td', text: project.name)
    click_link 'Project Roles'
    expect(page).to have_css('table tr td', text: project_role.name)
    click_link 'Members'
  end

  scenario 'shows active subject' do
    expect(page).to have_text('Logged in as:')
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
    expect(page)
      .to have_content("#{user.name} #{user.mail} Revoke" \
        'Confirm Revoke')
  end

  scenario 'shows Add User button' do
    expect(page).to have_content('Add User')
  end

  scenario 'shows Invite by email button' do
    expect(page).to have_content('Invite by email')
  end

  context 'revokes subject' do
    before { click_delete_button(text: 'Revoke') }

    scenario 'shows flash' do
      expect(page).to contain_rendered_content("Revoked #{project_role.name} " \
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

  context 'invite subject' do
    before { click_link('Invite by email') }

    scenario 'shows title' do
      expect(page).to have_text('Invite User to Project Role')
      expect(page).to have_text("#{project_role.name}")
    end

    scenario 'shows the form name field' do
      expect(page).to have_text('Name')
    end

    scenario 'shows the form email field' do
      expect(page).to have_text('Email')
    end

    scenario 'shows the form send invitation flag' do
      expect(page).to have_text('Send Invitation')
    end

    scenario 'shows the form send invitation flag as checked' do
      expect(find('#invitation_send_invitation').checked?).to be_truthy
    end

    scenario 'shows invite button' do
      expect(page).to have_button('Submit')
    end

    scenario 'has invite user path' do
      expect(current_path).to eq("/admin/organisations/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}/invitations/new")
    end

    context 'saves' do
      def last_invitation_url
        "http://www.example.com/invitations/#{Invitation.last.identifier}"
      end

      given(:name) { Faker::Name.name }
      given(:mail) { Faker::Internet.email }

      context 'with missing email' do
        before do
          fill_in 'invitation_name', with: name
          click_button 'Submit'
        end

        scenario 'shows flash message' do
          expect(page).to have_content('Error Mail can’t be blank')
        end
      end

      context 'with missing name' do
        before do
          fill_in 'invitation_mail', with: mail
          click_button 'Submit'
        end

        scenario 'shows flash message' do
          expect(page).to have_content('Error Name can’t be blank')
        end
      end

      context 'with no invitation' do
        before do
          fill_in 'invitation_mail', with: mail
          fill_in 'invitation_name', with: name
          find('#invitation_send_invitation').set(false)
          click_button 'Submit'
        end

        scenario 'redirects back to role' do
          expect(current_path).to eq('/admin/organisations' \
                                 "/#{organisation.id}/" \
                                 "projects/#{project.id}/" \
                                 "roles/#{project_role.id}")
        end

        scenario 'shows flash message' do
          expect(page).to contain_rendered_content('Success User has been' \
           " added to Project Role '#{project_role.name}'." \
           " Activate the account here: #{last_invitation_url}")
        end
      end

      context 'with an invitation' do
        before do
          fill_in 'invitation_mail', with: mail
          fill_in 'invitation_name', with: name
          click_button 'Submit'
        end

        scenario 'redirects back to role' do
          expect(current_path).to eq('/admin/organisations' \
                               "/#{organisation.id}/" \
                               "projects/#{project.id}/" \
                               "roles/#{project_role.id}")
        end

        scenario 'shows flash message' do
          expect(page).to contain_rendered_content('Success User has been' \
           " added to Project Role '#{project_role.name}'. An email has been " \
           "sent to #{mail}.")
        end

        context 'new subject' do
          given!(:user) { create(:subject, :authorized, permission: '*') }
          given(:new_subject) { Subject.last }
          given(:new_invitation) { Subject.last.invitations.first }
          given(:format) { '%a, %e %b %Y %H:%M:%S %z' }

          before { visit "/admin/subjects/#{new_subject.id}" }
          scenario 'viewing' do
            expect(Subject.last.invitations.size).to eq(1)
            expect(current_path).to eq("/admin/subjects/#{new_subject.id}")

            expect(page).to have_content("Name #{new_subject.name}")
            expect(page).to have_content("Email Address #{new_subject.mail}")
            expect(page).to have_content('State Pending Invitation')

            expect(page).to have_content('Email sent' \
             " #{new_invitation.last_email_sent_at.strftime(format)}")

            expect(page).to have_content("URL #{last_invitation_url}")
            expect(page).to have_content('Used No')
            expect(page).to have_content("Created #{new_invitation.created_at
                    .strftime(format)}")

            expect(page).to have_content("Expires #{new_invitation.expires
                                    .strftime(format)}")

            expect(page).to have_button('Resend')
          end

          context 'resend email' do
            before { click_button 'Resend' }
            scenario 'shows flash message' do
              expect(page).to have_content('Success' \
                " Sent email to #{new_invitation.mail}")
            end
          end
        end
      end
    end
  end

  context 'add subject' do
    given!(:another_user) do
      create(:subject, :authorized,
             permission: 'organisations:*')
    end

    before { click_link('Add User') }

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
        expect(page).to contain_rendered_content(
          "Granted #{project_role.name} " \
                 "to #{another_user.name}")
      end

      scenario 'shows the subject name in the list' do
        expect(page).to have_css('table tr td', text: another_user.name)
      end

      scenario 'shows that subject is granted' do
        expect(page)
          .to contain_rendered_content("#{another_user.name} " \
           " #{another_user.mail} Revoke" \
              'Confirm Revoke')
      end
    end
  end
end
