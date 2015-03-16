unless ENV['AAF_DEV'].to_i == 1
  $stderr.puts <<-EOF
  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.
  If this is what you want, set the AAF_DEV environment variable to 1 before
  attempting to seed your database.
  EOF
  fail('Not proceeding, missing AAF_DEV=1 environment variable')
end

require 'faker'
require 'factory_girl'

ActiveRecord::Base.transaction do
  FactoryGirl.lint
  fail(ActiveRecord::Rollback)
end

include FactoryGirl::Syntax::Methods

ActiveRecord::Base.transaction do
  Subject.all.offset(1).destroy_all
  Role.all.offset(1).destroy_all
  Organisation.destroy_all

  (1..11).each do
    organisation = create :organisation
    (1..11).each do
      project = create :project, organisation: organisation
      (1..11).each do
        project_role = create :project_role, project: project
        (1..11).each do
          subject = create :subject
          project_role.subjects << subject
        end
      end
    end
  end
end
