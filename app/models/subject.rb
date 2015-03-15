class Subject < ActiveRecord::Base
  include Accession::Principal
  include Filterable

  audited
  has_associated_audits

  # AWS project roles
  has_many :subject_project_roles, dependent: :destroy
  has_many :project_roles, through: :subject_project_roles

  # SPIN roles
  has_many :subject_roles, dependent: :destroy
  has_many :roles, through: :subject_roles

  has_many :invitations, dependent: :destroy

  validates :mail, uniqueness: { unless: :complete? }
  validates :targeted_id, :shared_token, presence: true, if: :complete?
  validates :complete, :enabled, inclusion: { in: [true, false] }

  valhammer

  def self.find_by_federated_id(attrs)
    if attrs[:shared_token] && attrs[:targeted_id]
      where(arel_table[:shared_token].eq(attrs[:shared_token])
        .or(arel_table[:targeted_id].eq(attrs[:targeted_id])))
        .first
    else
      fail('Refusing to find by nil value')
    end
  end

  def self.filter(query)
    t = Subject.arel_table

    query.to_s.downcase.split(/\s+/).map { |s| prepare_query(s) }
      .reduce(Subject) do |a, e|
        a.where(t[:name].matches(e))
      end
  end

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
