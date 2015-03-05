class Invitation < ActiveRecord::Base
  audited

  belongs_to :subject

  attr_accessor :send_invitation

  valhammer

  validates :identifier, format: { with: /\A[\w-]+\z/ }
end
