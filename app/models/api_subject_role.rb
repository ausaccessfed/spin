class APISubjectRole < ActiveRecord::Base
  audited associated_with: :api_subject

  belongs_to :api_subject
  belongs_to :role

  validates :api_subject, presence: true, uniqueness:
                            { scope: :role,
                              message: 'already has this role granted' }
  validates :role, presence: true
end
