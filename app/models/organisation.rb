class Organisation < ActiveRecord::Base
  audited
  has_many :projects, dependent: :destroy

  validates :name, :external_id, presence: true
  validates :external_id, uniqueness: true
end
