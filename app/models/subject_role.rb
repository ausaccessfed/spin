class SubjectRole < ActiveRecord::Base
  audited associated_with: :subject

  belongs_to :subject
  belongs_to :role

  valhammer

  validates :subject, uniqueness: { scope: :role,
                                    message: 'already has this role granted' }
end
