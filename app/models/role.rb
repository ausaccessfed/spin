class Role < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited

  has_many :permissions, dependent: :destroy
  has_many :subject_roles, dependent: :destroy
  has_many :api_subject_roles, dependent: :destroy

  has_many :subjects, through: :subject_roles
  has_many :api_subjects, through: :api_subject_roles

  valhammer
end
