class Invitation < ActiveRecord::Base
  include Lipstick::AutoValidation
  audited

  belongs_to :subject

  attr_accessor :send_invitation

  valhammer

  validates :identifier, format: { with: /\A[\w-]+\z/ }

  scope :current, -> { where(arel_table[:expires].gt(Time.now)) }
  scope :available, -> { current.where(used: false) }

  def expired?
    expires < Time.now
  end

  def active_project_present?
    subject.active_project_roles.present?
  end

  def project_name
    subject.active_project_roles.first.project.name
  end
end
