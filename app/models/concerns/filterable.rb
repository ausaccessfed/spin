module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def prepare_query(query)
      "*#{query}*".gsub(/[%*]+/, '%')
    end
  end
end
