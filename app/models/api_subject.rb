class APISubject < ActiveRecord::Base
  include Accession::Principal

  audited
  has_associated_audits

  has_many :api_subject_roles, dependent: :destroy
  has_many :roles, through: :api_subject_roles

  valhammer

  validates :x509_cn, format: { with: /\A[\w-]+\z/ }

  def permissions
    roles.flat_map { |role| role.permissions.map(&:value) }
  end

  def functioning?
    enabled?
  end
end
