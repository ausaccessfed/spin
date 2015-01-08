class APISubject < ActiveRecord::Base
  include Accession::Principal

  audited
  has_associated_audits

  has_many :api_subject_roles, dependent: :destroy
  has_many :roles, through: :api_subject_roles

  validates :description, :contact_name, :contact_mail,
            presence: true
  validates :x509_cn, presence: true, format: { with: /\A[\w-]+\z/ },
                      uniqueness: true
  validates :enabled, inclusion: { in: [true, false] }

  def permissions
    roles.flat_map { |role| role.permissions.map(&:value) }
  end

  def functioning?
    enabled?
  end
end
