class Organisation < ActiveRecord::Base
  audited
  has_many :projects
end
