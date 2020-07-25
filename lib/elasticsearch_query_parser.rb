require "parslet"
require "ostruct"
require_relative "elasticsearch_query_parser/sentence"
require_relative "elasticsearch_query_parser/grammar/parser"
require_relative "elasticsearch_query_parser/grammar/transformer"

# Mail ElasticsearchQueryParser interface
module ElasticsearchQueryParser
  # Gem configuration object
  # For now only contain 1 attribute: `elastic_field_name` option (by default :text)
  # Responds with OpenStruct entity which responds_to `elastic_field_name`
  # Example:
  #   >> ElasticsearchQueryParser.configuration
  #   => #<OpenStruct elastic_field_name=:text>
  def self.configuration
    @configuration ||= OpenStruct.new(
      elastic_field_name: :text
    )
  end

  # For gem configuration
  # For now only `elastic_field_name` can be modified. See README.md for details
  def self.configure
    yield(configuration)
  end

  # Parse given string into Elastic query object (see README.md for more examples)
  # Example:
  #  >> ElasticsearchQueryParser.parse_query("London")
  #  => { query: { bool: { should: [{ match: { text: { query: "London", operator: "and" } } }] } } }
  def self.parse_query(user_query)
    query = Sentence.new(user_query).to_s

    return {} if query.to_s.empty?

    parse_tree = Grammar::Parser.new.parse(query)
    transformed_query = Grammar::Transformer.new.apply(parse_tree)
    { query: transformed_query.to_elasticsearch }
  rescue Parslet::ParseFailed => e
    raise ParseFailedException, e.parse_failure_cause
  end

  class ParseFailedException < StandardError
    attr_reader :parse_failure_cause
    private :parse_failure_cause

    def initialize(parse_failure_cause)
      @parse_failure_cause = parse_failure_cause
      super
    end
  end
end
