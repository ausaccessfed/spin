class Subject < ActiveRecord::Base
  include Accession::Principal

  audited
  has_associated_audits
  has_many :subject_roles
  has_many :roles, through: :subject_roles

  validates :name, :mail, presence: true
  validates :targeted_id, :shared_token, presence: true, if: :complete?
  validates :shared_token, uniqueness: true, allow_nil: true
end
