class Subject < ActiveRecord::Base
  include Accession::Principal

  audited
  has_associated_audits
  has_many :subject_project_roles
  has_many :project_roles, through: :subject_project_roles

  validates :name, :mail, presence: true
  validates :targeted_id, :shared_token, presence: true, if: :complete?
  validates :shared_token, uniqueness: true, allow_nil: true

  def unique_project_ids
    project_roles.map(&:project_id).uniq
  end

  def projects
    Project.find(unique_project_ids)
  end

  def active_project_count
    unique_project_ids.count
  end
end
