class Organisation < ActiveRecord::Base
  audited
  has_many :projects

  validates :name, :external_id, presence: true
  validates :external_id, uniqueness: true
end
