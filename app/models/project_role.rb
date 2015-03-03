class ProjectRole < ActiveRecord::Base
  ROLE_ARN_REGEX = /\Aarn:aws:iam::\d+:role\/[A-Za-z0-9\+\=\,\.\@\-\_]{1,64}\z/

  audited associated_with: :project
  has_associated_audits

  has_many :subject_project_roles, dependent: :destroy
  has_many :subjects, through: :subject_project_roles
  belongs_to :project

  valhammer

  validates :role_arn, format: {
    with: ROLE_ARN_REGEX,
    message: 'format must be \'arn:aws:iam::' \
                                   '(number):role/(string)\'' },
                       role_arn_belongs_to_project: true

  before_validation :strip_role_arn_whitespace

  private

  def strip_role_arn_whitespace
    self.role_arn = role_arn.strip if role_arn
  end
end
