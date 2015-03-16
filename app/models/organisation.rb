class Organisation < ActiveRecord::Base
  include Filterable

  audited
  has_many :projects, dependent: :destroy
  valhammer

  def self.filter(query)
    t = Organisation.arel_table

    query.to_s.downcase.split(/\s+/).map { |s| prepare_query(s) }
      .reduce(Organisation) do |a, e|
        a.where(t[:name].matches(e).or(t[:unique_identifier].matches(e)))
      end
  end
end
