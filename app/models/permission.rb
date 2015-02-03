class Permission < ActiveRecord::Base
  audited associated_with: :role

  belongs_to :role

  validates :role, :value, presence: true
  validates :value, uniqueness: { scope: :role }

  # "word" in the url-safe base64 alphabet, or single '*'
  SEGMENT = /([\w-]+|\*)/
  private_constant :SEGMENT
  validates :value, presence: true, format: Accession::Permission.regexp
end
