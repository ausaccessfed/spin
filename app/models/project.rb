class Project < ActiveRecord::Base
  audited
  has_associated_audits
  belongs_to :organisation
  has_many :roles
end
