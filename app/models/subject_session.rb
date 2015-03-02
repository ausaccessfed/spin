class SubjectSession < ActiveRecord::Base
  validates :remote_addr, :subject, presence: true
  belongs_to :subject

  valhammer
end
