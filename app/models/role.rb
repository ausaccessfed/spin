class Role < ActiveRecord::Base
  audited associated_with: :project
  has_associated_audits

  has_many :subject_roles
  has_many :subjects, through: :subject_roles
  belongs_to :project

  validates :project, :name, :aws_identifier, presence: true
end
