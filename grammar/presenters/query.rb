module Grammar
  module Presenters
    class Query
      attr_reader :terms, :operator, :nested_query
      private :terms, :operator, :nested_query

      SEARCH_FIELD_NAME = :text

      def initialize(terms, operator, nested_query)
        @terms = terms
        @operator = operator
        @nested_query = nested_query
      end

      # If its `must_not` operator - just add `must_not` to root node and continue analyze nested queries
      # Otherwise for nested query add new nested nodes
      def to_elasticsearch(include_bool_header = true)
        query = if operator.to_elasticsearch == :must_not
          result = nested_query[0].to_elasticsearch(false)
          result.merge(must_not: result.fetch(:must_not, []) + match_query(terms))
        else
          { operator.to_elasticsearch => match_query(terms + nested_query) }
        end
        include_bool_header ? { bool: query } : query
      end

      private

      # if is a term then build match query, otherwise (nested query) - just add to query as is
      def match_query(sentence)
        sentence.map do |expression|
          if expression.is_a?(Term)
            { match: { SEARCH_FIELD_NAME => expression.to_elasticsearch } }
          else
            expression.to_elasticsearch
          end
        end
      end
    end
  end
end
