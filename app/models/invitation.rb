class Invitation < ActiveRecord::Base
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

  def project_name
    subject.project_roles.first.project.name
  end
end
