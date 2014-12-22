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
    def subject(_env, attrs)
      Rails.logger.info('Find or update Subject using attributes: ' \
                            "#{attrs.inspect}")
      identifier = attrs.slice(:targeted_id)
      Rails.logger.info("Using identifier: #{identifier}")
      Subject.find_or_initialize_by(identifier).tap do |subject|
        subject.update_attributes!(attrs)
        Rails.logger.info('Updated or created Subject')
      end
    end

    def finish(env)
      return unless env['rack.session']
      subj = Subject.find(env['rack.session']['subject_id'])
      distinct_project_roles = subj.project_roles.select(:project_id).distinct
      if (distinct_project_roles.count == 0)
        redirect_to('/no_projects_assigned')
      elsif (distinct_project_roles.count == 1)
        redirect_to('/aws_idp')
      else
        redirect_to('/projects')
      end
    end
  end
end
