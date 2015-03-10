class Organisation < ActiveRecord::Base
  audited
  has_many :projects, dependent: :destroy
  valhammer

  filterrific(
      default_filter_params: { sorted_by: 'name_desc' },
      available_filters: [
          :sorted_by,
          :search_query
      ]
  )

  scope :search_query, lambda { |query|
      return nil if query.blank?
      terms = query.to_s.downcase.split(/\s+/)
      terms = terms.map { |e|
        (e.gsub('*', '%') + '%').gsub(/%+/, '%')
      }
      num_or_conditions = 2
      where(
       terms.map {
         or_clauses = [
             "LOWER(organisations.name) LIKE ?",
             "LOWER(organisations.unique_identifier) LIKE ?"
         ].join(' OR ')
         "(#{ or_clauses })"
       }.join(' AND '),
       *terms.map { |e| [e] * num_or_conditions }.flatten
      )
    }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^name_/
        order("LOWER(organisations.name) #{ direction }")
      when /^unique_identifier_/
        order("LOWER(organisations.unique_identifier) #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
end
