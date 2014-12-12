class Subject < ActiveRecord::Base
  has_many :subject_roles
  has_many :roles, through: :subject_roles
  include Accession::Principal

  validates :name, :mail, presence: true
  validates :targeted_id, :shared_token, presence: true, if: :complete?
end
