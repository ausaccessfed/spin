class SubjectProjectRole < ActiveRecord::Base
  audited associated_with: :subject

  belongs_to :subject
  belongs_to :project_role

  validates :subject, :project_role, presence: true
  validates :project_role, uniqueness: { scope: :subject }
end
