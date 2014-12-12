class Project < ActiveRecord::Base
  belongs_to :organisation
  has_many :roles
end
