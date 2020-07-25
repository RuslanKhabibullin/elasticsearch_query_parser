require_relative "presenters/operator"
require_relative "presenters/query"
require_relative "presenters/term"

module ElasticsearchQueryParser
  module Grammar
    # Transform rules (accept PEG trees) from Parslet grammar and modify trees according to described rules
    class Transformer < ::Parslet::Transform
      # Base grammar atom (leaf)
      rule(term: simple(:term)) { Presenters::Term.new(term) }

      # It can be simple tree with terms only - query: [{term}, {term}, ...]
      # Or it can be deeply nested tree with sub queries
      rule(query: subtree(:query)) do
        if query.all? { |element| element.is_a?(Presenters::Term) }
          Presenters::Query.new(
            query,
            Presenters::Operator.new("OR"),
            []
          )
        else
          # Retrieve nested query
          query[0]
        end
      end

      # Nested query rule
      rule(term: simple(:term), operator: simple(:operator), query: subtree(:query)) do
        Presenters::Query.new(
          [Presenters::Term.new(term)],
          Presenters::Operator.new(operator),
          query
        )
      end
    end
  end
end
