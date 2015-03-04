class Invitation < ActiveRecord::Base
  audited

  belongs_to :subject

  valhammer

  validates :identifier, format: { with: /\A[\w-]+\z/ }
end
