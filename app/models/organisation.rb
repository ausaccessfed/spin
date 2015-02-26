class Organisation < ActiveRecord::Base
  audited
  has_many :projects, dependent: :destroy

  validates :name, :unique_identifier, presence: true
  validates :unique_identifier, uniqueness: true
end
