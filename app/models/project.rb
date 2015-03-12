class Project < ActiveRecord::Base
  PROVIDER_ARN_REGEX =
      /\Aarn:aws:iam::\d+:saml-provider\/[A-Za-z0-9\.\_\-]{1,128}\z/

  audited associated_with: :organisation
  has_associated_audits

  belongs_to :organisation
  has_many :project_roles, dependent: :destroy

  valhammer

  validates :provider_arn, format: {
    with: PROVIDER_ARN_REGEX,
    message: 'format must be \'arn:aws:iam:' \
                                      ':(number):saml-provider/(string)\'' }

  before_validation :strip_provider_arn_whitespace

  def self.filter(query)
    t = Project.arel_table

    query.to_s.downcase.split(/\s+/).map { |s| prepare_query(s) }
      .reduce(Project) do |a, e|
        a.where(t[:name].matches(e))
      end
  end

  def self.prepare_query(query)
    (query.gsub('*', '%') + '%').gsub(/%+/, '%')
  end

  private

  def strip_provider_arn_whitespace
    self.provider_arn = provider_arn.strip if provider_arn
  end
end
