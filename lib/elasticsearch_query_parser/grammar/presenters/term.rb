module ElasticsearchQueryParser
  module Grammar
    module Presenters
      class Term
        attr_reader :term
        private :term

        def initialize(term)
          @term = term.to_s
        end

        def to_elasticsearch
          {
            query: term,
            operator: "and"
          }
        end
      end
    end
  end
end
