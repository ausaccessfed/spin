class SubjectRole < ActiveRecord::Base
  audited associated_with: :subject

  belongs_to :subject
  belongs_to :role

  validates :subject, :role, presence: true
  validates :subject, uniqueness:
                        { scope: :role,
                          message: 'already has this role granted' }
end
