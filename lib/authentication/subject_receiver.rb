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
      Rails.logger.info('Find or update Subject using attributes: ' \
                            "#{attrs.inspect}")
      identifier = attrs.slice(:targeted_id)
      Rails.logger.info("Using identifier: #{identifier}")
      Subject.transaction do
        Subject.find_or_initialize_by(identifier).tap do |subject|
          subject.update_attributes!(attrs)
          create_session_record(env, subject)
        end
      end
    end

    def create_session_record(env, subject)
      SubjectSession.create!(remote_host: env['REMOTE_HOST'],
                             remote_addr: env['REMOTE_ADDR'],
                             http_user_agent:  env['HTTP_USER_AGENT'],
                             subject: subject)
    end

    def finish(env)
      return unless env['rack.session']
      subject = Subject.find(env['rack.session']['subject_id'])
      return redirect_to('/dashboard') if subject.roles.any?
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
