class APISubjectRole < ActiveRecord::Base
  audited associated_with: :api_subject

  belongs_to :api_subject
  belongs_to :role

  valhammer

  validates :api_subject, uniqueness:
                            { scope: :role,
                              message: 'already has this role granted' }
end
