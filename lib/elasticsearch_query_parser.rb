require "parslet"
require_relative "sentence"
require_relative "grammar/parser"
require_relative "grammar/transformer"

class ElasticsearchQueryParser
  attr_reader :query
  private :query

  def initialize(user_query)
    @query = Sentence.new(user_query).to_s
  end

  def call
    return {} if query.to_s.empty?

    parse_tree = parser.parse(query)
    transformed_query = transformer.apply(parse_tree)
    { query: transformed_query.to_elasticsearch }
  rescue Parslet::ParseFailed => e
    puts e.parse_failure_cause.ascii_tree
  end

  private

  def parser
    @parser ||= Grammar::Parser.new
  end

  def transformer
    @transformer ||= Grammar::Transformer.new
  end
end
