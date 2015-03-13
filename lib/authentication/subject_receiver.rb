module Authentication
  class SubjectReceiver
    # Helper mixin which provides default behaviour for the Receiver class
    include RapidRack::DefaultReceiver

    # Default implementation of Redis-backed replay detection
    include RapidRack::RedisRegistry

    # Receives the contents of the 'https://aaf.edu.au/attributes' claim from
    # Rapid Connect, and returns a set of attributes appropriate for passing in
    # to the `subject` method.
    def map_attributes(_env, attrs)
      Rails.logger.info("Mapping attributes: #{attrs.inspect}")
      {
        targeted_id: attrs['edupersontargetedid'],
        shared_token: attrs['auedupersonsharedtoken'],
        name: attrs['displayname'],
        mail: attrs['mail']
      }
    end

    # Receives a set of attributes returned by `map_attributes`, and is
    # responsible for either creating a new user record, or updating an existing
    # user record to ensure attributes are current.
    #
    # Must return the subject, and the subject must have an `id` method to work
    # with the DefaultReceiver mixin.
    def subject(env, attrs)
      session = env['rack.session']
      return use_invitation(session, attrs, env) if invited_user?(session)
      identifier = attrs.slice(:targeted_id)
      Subject.transaction do
        Subject.find_or_initialize_by(identifier).tap do |subject|
          subject.update_attributes!(attrs.merge(complete: true))
          create_session_record(env, subject)
        end
      end
    end

    def invited_user?(session)
      return false unless invite_key?(session)
      identifier = session[:invite]
      invitation = Invitation.find_by_identifier(identifier)
      invitation && !invitation.used?
    end

    def invite_key?(session)
      session.try(:key?, :invite)
    end

    def use_invitation(session, attrs, env)
      Invitation.transaction do
        invitation = Invitation.where(identifier: session[:invite])
                     .available.first!
        subject = find_subject_for_session(attrs, invitation)
        subject.accept(invitation, attrs)
        create_session_record(env, subject)
        subject
      end
    end

    def find_subject_for_session(attrs, invitation)
      subject = Subject.find_by_federated_id(attrs)

      if subject
        merge_existing_subject(invitation, subject)
      else
        subject = invitation.subject
      end
      subject
    end

    def merge_existing_subject(invitation, subject)
      copy_project_roles(invitation, subject)
      original_subject = invitation.subject
      original_subject.audit_comment = merge_comment(invitation, subject)
      invitation.update_attributes!(subject_id: subject.id,
                                    audit_comment: merge_comment(invitation,
                                                                 subject))
      original_subject.destroy!
    end

    def copy_project_roles(invitation, subject)
      invitation.subject.project_roles.each do |project_role|
        subject_project_role_map = { subject_id: subject.id,
                                     project_role_id: project_role.id }
        next unless SubjectProjectRole.find_by(subject_project_role_map).nil?
        SubjectProjectRole.create!(subject_project_role_map.merge(
                                     audit_comment: merge_comment(invitation,
                                                                  subject)))
      end
    end

    def merge_comment(invitation, subject)
      "Merging from Subject #{invitation.subject.id} to #{subject.id}"
    end

    def create_session_record(env, subject)
      SubjectSession.create!(remote_host: env['REMOTE_HOST'],
                             remote_addr: env['REMOTE_ADDR'],
                             http_user_agent:  env['HTTP_USER_AGENT'],
                             subject: subject)
    end

    def finish(env)
      session = env['rack.session']
      return unless session
      subject = Subject.find(env['rack.session']['subject_id'])
      return redirect_to('/dashboard') if subject.roles.any?
      if invite_key?(session)
        session.delete(:invite)
        return redirect_to('/invitation_complete')
      end
      redirect_subject(subject)
    end

    def redirect_subject(subject)
      case subject.active_project_roles.count
      when 0
        redirect_to('/dashboard')
      when 1
        redirect_to('/aws_login')
      else
        redirect_to('/projects')
      end
    end
  end
end
