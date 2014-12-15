class Project < ActiveRecord::Base
  audited associated_with: :organisation
  has_associated_audits

  belongs_to :organisation
  has_many :roles

  validates :organisation, :name, :aws_account, :state, presence: true
end
