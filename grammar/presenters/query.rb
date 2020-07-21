module Grammar
  module Presenters
    class Query
      attr_accessor :terms

      def initialize(terms)
        @terms = terms
      end

      def to_elasticsearch
        {
          :query => {
            :match => {
              :title => {
                :query => terms.join(" "),
                :operator => "or"
              }
            }
          }
        }
      end
    end
  end
end
