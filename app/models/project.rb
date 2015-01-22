class Project < ActiveRecord::Base
  PVD_ARN_REGEX = /\Aarn:aws:iam::\d+:saml-provider\/[A-Za-z0-9\.\_\-]{1,128}\z/

  audited associated_with: :organisation
  has_associated_audits

  belongs_to :organisation
  has_many :project_roles, dependent: :destroy

  validates :organisation, :name, :state, presence: true

  validates :provider_arn, presence: true,
                           format: {
                             with: PVD_ARN_REGEX,
                             message: 'format must be \'arn:aws:iam:' \
                                      ':(number):saml-provider/(string)\'' }
end
