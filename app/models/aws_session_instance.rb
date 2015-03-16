class AWSSessionInstance < ActiveRecord::Base
  belongs_to :subject
  belongs_to :project_role

  valhammer

  validates :identifier, format: /\A[\w-]{40}\z/

  after_initialize :generate_identifier

  private

  def generate_identifier
    self.identifier ||= SecureRandom.urlsafe_base64(30)
  end
end
