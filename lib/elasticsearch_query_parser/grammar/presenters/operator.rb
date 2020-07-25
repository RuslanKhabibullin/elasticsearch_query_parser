module ElasticsearchQueryParser
  module Grammar
    module Presenters
      class Operator
        class InvalidOperatorString < StandardError
          attr_reader :string
          private :string

          def initialize(string)
            @string = string
            super
          end

          def message
            "Invalid operator: #{string}"
          end
        end

        attr_reader :operator
        private :operator

        def initialize(operator)
          @operator = (operator || "OR").to_s.downcase
        end

        def to_elasticsearch
          case operator
          when "and"
            :must
          when "not"
            :must_not
          when "or"
            :should
          else
            raise InvalidOperatorString, operator
          end
        end
      end
    end
  end
end
