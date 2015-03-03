class Organisation < ActiveRecord::Base
  audited
  has_many :projects, dependent: :destroy
  valhammer
end
