class SubjectRole < ActiveRecord::Base
  audited associated_with: :subject

  belongs_to :subject
  belongs_to :role

  validates :subject, :role, presence: true
end
