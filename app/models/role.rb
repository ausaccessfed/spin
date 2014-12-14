class Role < ActiveRecord::Base
  audited
  has_associated_audits
  has_many :subject_roles
  has_many :subjects, through: :subject_roles
  belongs_to :project
end
