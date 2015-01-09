class APISubjectRole < ActiveRecord::Base
  audited associated_with: :api_subject

  belongs_to :api_subject
  belongs_to :role

  validates :api_subject, presence: true
  validates :role, presence: true, uniqueness: { scope: :api_subject }
end
