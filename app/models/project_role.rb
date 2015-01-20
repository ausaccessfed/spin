class ProjectRole < ActiveRecord::Base
  audited associated_with: :project
  has_associated_audits

  has_many :subject_project_roles, dependent: :destroy
  has_many :subjects, through: :subject_project_roles
  belongs_to :project

  validates :project, :name, :role_arn, presence: true
end
