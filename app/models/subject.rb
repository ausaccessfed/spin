class Subject < ActiveRecord::Base
  include Accession::Principal

  validates :name, :mail, presence: true
  validates :targeted_id, :shared_token, presence: true, if: :complete?
end
