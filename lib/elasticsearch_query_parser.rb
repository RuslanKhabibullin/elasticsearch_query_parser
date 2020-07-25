require "parslet"
require "ostruct"
require_relative "elasticsearch_query_parser/sentence"
require_relative "elasticsearch_query_parser/grammar/parser"
require_relative "elasticsearch_query_parser/grammar/transformer"

module ElasticsearchQueryParser
  def self.configuration
    @configuration ||= OpenStruct.new(
      elastic_field_name: :text
    )
  end

  def self.configure
    yield(configuration)
  end

  def self.parse_query(user_query)
    query = Sentence.new(user_query).to_s

    return {} if query.to_s.empty?

    parse_tree = Grammar::Parser.new.parse(query)
    transformed_query = Grammar::Transformer.new.apply(parse_tree)
    { query: transformed_query.to_elasticsearch }
  rescue Parslet::ParseFailed => e
    puts e.parse_failure_cause.ascii_tree
  end
end
