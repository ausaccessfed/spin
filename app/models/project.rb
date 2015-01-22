class Project < ActiveRecord::Base
  audited associated_with: :organisation
  has_associated_audits

  belongs_to :organisation
  has_many :project_roles, dependent: :destroy

  validates :organisation, :name, :aws_account, :state, presence: true
end
