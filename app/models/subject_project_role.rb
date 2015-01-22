class SubjectProjectRole < ActiveRecord::Base
  audited associated_with: :subject

  belongs_to :subject
  belongs_to :project_role

  validates :subject, :project_role, presence: true
  validates :subject, uniqueness: { scope: :project_role,
                                    message: 'already has this role granted' }
end
