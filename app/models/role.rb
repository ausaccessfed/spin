class Role < ActiveRecord::Base
  has_many :subject_roles
  has_many :subjects, through: :subject_roles
  belongs_to :project
end
