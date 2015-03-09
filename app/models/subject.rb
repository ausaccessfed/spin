class Subject < ActiveRecord::Base
  include Accession::Principal

  audited
  has_associated_audits

  # AWS project roles
  has_many :subject_project_roles, dependent: :destroy
  has_many :project_roles, through: :subject_project_roles

  # SPIN roles
  has_many :subject_roles, dependent: :destroy
  has_many :roles, through: :subject_roles

  has_many :invitations, dependent: :destroy

  validates :targeted_id, :shared_token, presence: true, if: :complete?
  validates :complete, :enabled, inclusion: { in: [true, false] }

  valhammer

  def functioning?
    enabled? && complete?
  end

  def permissions
    roles.flat_map { |role| role.permissions.map(&:value) }
  end

  def active_project_roles
    project_roles.select { |project_role| project_role.project.active }
  end

  def outstanding_invitations
    invitations.select { |invitation| !invitation.used? }
  end

  def accept(invitation, attrs)
    transaction do
      update_attributes!(attrs.merge(complete: true))
      invitation.update_attributes!(used: true)
    end
  end
end
