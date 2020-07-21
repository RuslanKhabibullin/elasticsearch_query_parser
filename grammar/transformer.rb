require_relative "presenters/query"

module Grammar
  class Transformer < ::Parslet::Transform
    rule(term: simple(:term)) { term.to_s }
    rule(query: sequence(:terms)) { Presenters::Query.new(terms) }
  end
end
